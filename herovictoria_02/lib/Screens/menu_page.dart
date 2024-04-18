import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class MenuPage extends StatelessWidget {
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<String> opciones = ['Proyecto Integrador II', 'Teleinformática II', 'Sistemas de Información'];
  String? opcionSelecionada = 'pi2';
  
  File? image;
  bool imageTaken = false;
  Position? position;
  final user = FirebaseAuth.instance.currentUser!;
  final DatabaseReference _locationRef =
    FirebaseDatabase.instance.reference().child('Cursos');
  final FirebaseStorage _storage = FirebaseStorage.instance; 

  Future pickImage() async {
    try{
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemporary = File(image.path);
      // Sube la imagen a Firebase Storage
      final imageURL = await uploadImageToFirebaseStorage(imageTemporary);

      // Asegúrate de que la posición no sea nula antes de llamar a la función
      if (position != null) {
        await guardarUbicacionConImagenEnBaseDeDatos(position!, imageURL);
      }
      setState(() {
        this.image = imageTemporary;
        imageTaken = true;
      });
    }on PlatformException catch (e){
      print('Fallo al tomar la imagen: $e');
    }
  }

  Future<String> uploadImageToFirebaseStorage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return '';

      final Reference storageReference = _storage
          .ref()
          .child('images/${user.uid}/${DateTime.now().toString()}.jpg');
      final UploadTask uploadTask = storageReference.putFile(imageFile);

      final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      final String imageURL = await snapshot.ref.getDownloadURL();

      return imageURL;
    } catch (e) {
      print('Error al cargar la imagen en Firebase Storage: $e');
      return '';
    }
  }

  Future<void> guardarUbicacionConImagenEnBaseDeDatos(
      Position position, String imageURL) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Guarda la URL de la imagen en la base de datos bajo la referencia _locationRef
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      String formattedTime = DateFormat('HH:mm:ss').format(now);

      String userEmail = user.email ?? "";
      String userName = display();

      if(opcionSelecionada == 'pi2'){
        final DatabaseReference locationRef2 = _locationRef.child('Proyecto Integrador II');
        locationRef2.push().set({
        'latitud': position.latitude,
        'longitud': position.longitude,
        'fecha': formattedDate,
        'hora': formattedTime,
        'correo': userEmail,
        'nombre': userName,
        'imageURL': imageURL,
      });

      }else if(opcionSelecionada == 'tele2'){
        final DatabaseReference locationRef1 = _locationRef.child('Teleinformática');
        locationRef1.push().set({
        'latitud': position.latitude,
        'longitud': position.longitude,
        'fecha': formattedDate,
        'hora': formattedTime,
        'correo': userEmail,
        'nombre': userName,
        'imageURL': imageURL,
      });

      }else if(opcionSelecionada == 'sist'){
        final DatabaseReference locationRef3 = _locationRef.child('Sistemas de Información');
        locationRef3.push().set({
        'latitud': position.latitude,
        'longitud': position.longitude,
        'fecha': formattedDate,
        'hora': formattedTime,
        'correo': userEmail,
        'nombre': userName,
        'imageURL': imageURL,
      });
      }

      Fluttertoast.showToast(
        msg: 'Datos guardados en Firebase Database.',
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error al guardar los datos en Firebase Database: $e',
      );
    }
  }

  double calculateTextSize(BuildContext context, double baseSize) {
    // Obtiene las dimensiones de la pantalla
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Calcula un tamaño de fuente proporcional
    double scaleFactor = (screenWidth + screenHeight) / 10; // Puedes ajustar este factor según tus preferencias
    return baseSize * (scaleFactor / 100);
  }

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('error');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

String display() {
    String email = user.email ?? "";
    switch (email) {
      case "2019235429@unfv.edu.pe":
        return "Paucar Jimenez Josef";
      case "2019015474@unfv.edu.pe":
        return "Ampuero Aldoradin Diego";
      case "2017003095@unfv.edu.pe":
        return "Bautista Rojas Rodrigo";
      case "2018026598@unfv.edu.pe":
        return "Velasco Ortega David";
      case "2017043631@unfv.edu.pe":
        return "Del Valle Azurin Isaac";      
      default:
        return "Nombre de Usuario Desconocido";
    }
  }

  Future obtenerUbicacionActual() async {
    try {
      Position newPosition = await determinePosition();
      setState(() {
        position = newPosition;
      });
      // Cambia la llamada a la función a guardarUbicacionConImagenEnBaseDeDatos
      //await guardarUbicacionConImagenEnBaseDeDatos(
      //newPosition, ""); // Debes proporcionar la URL de la imagen
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error al obtener la ubicación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = " ";
    String display (){
    switch (user.email){
      case "2019235429@unfv.edu.pe":
      name = "Paucar Jimenez Josef";
      break;
      case "2019015474@unfv.edu.pe":
      name = "Ampuero Aldoradin Diego";
      break;
       case "2017003095@unfv.edu.pe":
      name = "Bautista Rojas Rodrigo";
      break; 
       case "2018026598@unfv.edu.pe":
      name = "Velasco Ortega David";
      break; 
       case "2017043631@unfv.edu.pe":
      name = "Del Valle Azurin Isaac";
      break;   
    }
    return name;
 }

    return Scaffold(
      body: Stack( 
      children:[
        fondo(),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 230),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                  child:Text(
                    "Bienvenido:${display()}",
                    style: TextStyle(fontSize: calculateTextSize(context, 15), fontWeight: FontWeight.w900,color: Colors.black),
                    textAlign: TextAlign.left,
                  ),
                  ),

                  DropdownButton<String?>(
                    value: opcionSelecionada, 
                    onChanged: (String? nuevaOpcion){
                      setState(() {
                        opcionSelecionada = nuevaOpcion;
                      });
                    },
                    items: [
                      DropdownMenuItem<String?>(
                        value: 'pi2',
                        child: Text('Proyecto Integrador II'),
                        ),
                      DropdownMenuItem<String?>(
                        value: 'tele2',
                        child: Text("Teleinformática 2"),
                        ),
                      DropdownMenuItem<String?>(
                        value: 'sist',
                        child: Text('Sistemas de Información'),
                        ),
                    ]
                     ), 
                ]
              ),
              if (image != null)
              Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                width:300,
                height: 300,
                decoration: BoxDecoration(border: Border.all()),
                child:
                    Image.file(
                    image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: IconButton(
                    onPressed: () async {
                    obtenerUbicacionActual();
                    await pickImage();
                    },
                    icon: const Icon(Icons.camera_alt),
                    color: Colors.white,
                    ),
                    ),

                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: IconButton(
                    onPressed: imageTaken?() async {
                    showExitConfirmationToast();
                    }: null,
                    icon: const Icon(Icons.check),
                    color: Colors.white,
                    ),
                    ),
      
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: IconButton(
                    onPressed: () async {
                      FirebaseAuth.instance.signOut();
                      //exit(0);
                    },
                    icon: const Icon(Icons.exit_to_app),
                    color: Colors.white,
                    ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              ]
            ), 
          ),
        ],
      ),
    );
  }

  Widget fondo() {
    return Container(
      decoration:const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/Fondo.png'), // Ruta de la imagen de fondo
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  void showExitConfirmationToast() {
    DateTime now = DateTime.now();
    DateTime peruTime = now.subtract(Duration(hours: 5));
    String formattedDate = DateFormat('yyyy-MM-dd').format(peruTime);
    String formattedTime = DateFormat('HH:mm:ss').format(peruTime);

    Fluttertoast.showToast(
      msg: 'Asistencia confirmada',
      toastLength: Toast.LENGTH_LONG, // Adjust the length as needed
      gravity: ToastGravity.SNACKBAR,
      timeInSecForIosWeb: 7,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 18.0,
    );
    print('Fecha: $formattedDate');
    print('Hora: $formattedTime (Hora de Perú)');  
  }
}