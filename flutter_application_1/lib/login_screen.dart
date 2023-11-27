//import 'package:contact_google_sign_in/google_contact_model.dart';
import 'dart:ffi';
import 'dart:io' as IO;
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:gmail_google_sign_in/main.dart';
import 'package:googleapis/driveactivity/v2.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/serviceconsumermanagement/v1.dart';
import 'package:http/http.dart' as http;
import 'message.dart';
import 'dart:convert';
import 'package:googleapis/gmail/v1.dart' as gMail;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}



class _LoginScreenState extends State<LoginScreen> {
  GoogleSignIn _googleSignIn;
  GoogleSignInAccount _currentUser;
  List<MessageConstructor> _currentImage = [];
  String checkIfEndReached = '';
  String  Label_1 = 'Label_1199390694113472169';
  bool isLoading = true;
  String inputValue = '';
  var _currentheader;
  var  _decodedBytes = null;

  bool checkIfImage(filetype) => filetype =='image/png' || filetype =='image/jpg' || filetype =='image/jpeg';


  Future getUserContacts() async {

      
    final host = "https://gmail.googleapis.com/gmail/v1/users/pratyushnarain97@gmail.com/messages/";
    // final endPoint =
    //     "/v1/people/me/connections?personFields=names,phoneNumbers";
   // print(host);
    var header = await _currentUser.authHeaders;
    final httpClient = await _googleSignIn.authenticatedClient();
    setState(() {
        _currentheader = header;
      });
    
    header['Accept'] = 'application/json';
    header['Content-type'] = 'application/json';
    var c = 0;
    final data = await gMail.GmailApi(httpClient).users.messages.list("me",maxResults: 50); 

    List<MessageConstructor> getList = [];
    //testingEmail('pratyushnarain97@gmail.com',header);  
    for (gMail.Message message in data.messages) {
      
       if(message.id==checkIfEndReached){
          break;
       }
      //var todayDate = DateFormat("yyyy-MM-dd hh:mm:ss").format(message.internalDate);
      gMail.Message messageData = await gMail.GmailApi(httpClient).users.messages.get("me", message.id);
      if (messageData.payload!=null && messageData.payload.parts!=null){
      if ((messageData.labelIds.contains('CATEGORY_PERSONAL') || messageData.labelIds.contains('IMPORTANT')) && (messageData.labelIds.contains(Label_1)==false)){
        MessageConstructor newMessage = MessageConstructor();
        newMessage.content = '';
        newMessage.content = messageData.snippet;
        newMessage.threadId = messageData.threadId;
        newMessage.id = messageData.id;
        newMessage.attachmentpayload = List.empty(growable: true);
        for (final part in messageData.payload.parts){
          if(part.filename!=null && checkIfImage(part.mimeType)){
            if (part.body.data!=null){
                var d1 = part.body.data; 
                Uint8List decodedByte = base64Decode(d1);
                print(decodedByte);
            }
            else if(part.body.attachmentId!=null){
              final att_id = part.body.attachmentId;
              Image image;
              final att = await gMail.GmailApi(httpClient).users.messages.attachments.get('me', message.id, att_id);
              var data1 = att.data;

              newMessage.subject = '';
              newMessage.date = '';
              
              for (var headerpart in messageData.payload.headers){
                if(headerpart.name == "Subject"){
                  
                  newMessage.subject = headerpart.value;
            
                }
                if(headerpart.name == "Date"){
                  newMessage.date = headerpart.value;
                }
                if(headerpart.name == "From"){
                  newMessage.from = headerpart.value;
                }
                if(headerpart.name == "Message-ID"){
                  var toFirstString = headerpart.value.split('\u003c');
                  var toSecString = toFirstString[1].split('\u003e');
                  newMessage.MsgID = toSecString[0];
                  print(newMessage.MsgID);

                }
              }
              Uint8List decodedByte = base64Decode(data1);
              newMessage.attachmentpayload.add(decodedByte);
              
              getList.add(newMessage);
              

              // final decodedByte = base64Decode(data1);
              
              // _decodedBytes = image;
          }
          
          //Image.memory(base64Decode(data));
          //final base64Str = base64.encode(data); 
          //print(data.toString());       
       
          
        }
      
    }
      }
    
      
    }
    }
    List<MessageConstructor> reversedGetList = getList.reversed.toList();
    setState(() {
      reversedGetList.forEach((e) => _currentImage.insert(0, e));
    });
    if (_currentImage.length>0){
      setState(() {
       checkIfEndReached = _currentImage[0].id;
    });
      
    }
    else{
      setState(() {
       isLoading = false;
    });
    }

    print(_currentImage.length);
  }
    
  

    //print(data);
    // final request = await http.get("$host", headers: header);
    // print("Loading completed");
    
    // if (request.statusCode == 200) {
    //   print("Api working perfect");
    //   print(request.body);
      
    // } else {
    //   print("Api got error");
    //   print(request.body);
    // }
  
  void showErrorMessage(BuildContext context, String errorMessage) => Flushbar(
      duration: Duration(seconds: 2),
      padding: EdgeInsets.all(24),
      backgroundGradient: LinearGradient(
        colors: [Colors.red, Colors.orange]
      ),
      icon: Icon(Icons.check,size: 32,color: Colors.white),
      message: errorMessage,
      flushbarPosition: FlushbarPosition.TOP,
    )..show(context);

  void showSuccessMessage(BuildContext context, String successMessage) => Flushbar(
      duration: Duration(seconds: 2),
      padding: EdgeInsets.all(24),
      backgroundGradient: LinearGradient(
        colors: [Colors.greenAccent, Colors.green]
      ),
      icon: Icon(Icons.check,size: 32,color: Colors.white),
      message: successMessage,
      flushbarPosition: FlushbarPosition.TOP,
    )..show(context);
   
  
  Future<Null> sendMail(String userId, header,MessageConstructor m,String inputValue) async {
    var Message = {};
    var from = userId;
    var to = m.from;
    var toFirstString = to.split('\u003c');
    var toSecString = toFirstString[1].split('\u003e');
    var threadId = m.threadId;
    var subject = 'test send email';
    Message['from'] = from;
    Message['to'] = to;
    Message['subject'] = subject;
    print(header);
  //var message = 'worked!!!';
    var message = "Html Email";
    var content = 'From: <${userId}>\n'
'To: <${toSecString[0]}>\n'
'Subject: ${m.subject}\n'
 'In-Reply-To: <${m.MsgID}>\n'
  'Reference: <${m.MsgID}>\n'
'\n'
'${inputValue}\n';

  var bytes = utf8.encode(content);
  var base64 = base64Encode(bytes);
  //print(base64);
  var body = json.encode({
    
      'raw': base64,'threadId': threadId
    });
  //String url = 'https://www.googleapis.com/gmail/v1/users/' + userId + '/messages/send';
  String url = 'https://gmail.googleapis.com/gmail/v1/users/${userId}/messages/send';

  final http.Response response = await http.post(
    url,
    headers: header,
    body: body
  );
  if (response.statusCode != 200) {
    showErrorMessage(context,'error: ' + response.body);
    return;
    
  }
  else{
      String url = 'https://gmail.googleapis.com/gmail/v1/users/${userId}/messages/${m.id}/modify';
      var body1 = jsonEncode(
            
              {
            "addLabelIds":  [Label_1],
            "removeLabelIds": []

            
            
    });
      final http.Response response = await http.post(
      url,
      headers: header,
      body: body1
    );
    if (response.statusCode != 200) {
      setState(() {
        showErrorMessage(context,'error: ' + response.body);
      }); 
      return;
  }
  else{
     _currentImage.remove(m);
    showSuccessMessage(context,'Mail sent');

   
  }
  

  final Map<String, dynamic> data = json.decode(response.body);
  print('ok: ' + response.statusCode.toString());
}
}
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _googleSignIn = GoogleSignIn(
      clientId: "323035260138-3uorg27ghg4a33n2ff6lnd0nd36g5au2.apps.googleusercontent.com",
      scopes: 
      <String>[gMail.GmailApi.gmailReadonlyScope, gMail.GmailApi.gmailSendScope, gMail.GmailApi.gmailLabelsScope,gMail.GmailApi.gmailModifyScope],
      // "https://www.googleapis.com/auth/gmail.readonly",
     
    );
    _googleSignIn.onCurrentUserChanged.listen((user) {
      setState(() {
        _currentUser = user;

      });
        var d = getUserContacts();
       // print(_currentUser.displayName);
      });
  }

  Widget ShowImage(image){
    return Column(children:[
      Text('image'),
    ]
    );
  }
  Widget getLoginWidget(){
    return Column(children: [
      Text("Login to continue"),
      SizedBox(height: 16),
      ElevatedButton(
        style:  ElevatedButton.styleFrom(textStyle: GoogleFonts.rubik(fontSize: 15)),       
        onPressed: () async {
            try {
              await _googleSignIn.signIn();
            } on Exception catch (e) {
              print(e);
            }
          },
      child: Text("Google sign in"))
    ],);
  }
    Widget getTextWidgets(List<String> strings)
  {
    return new Row(children: strings.map((item) => new Text(item)).toList());
  }

  Widget getContactListWidget(){ 
        return Scaffold(

      body:
      _currentImage != null && isLoading == false ? 

      Text('No result found') : 
      _currentImage != null && _currentImage.length>0 ? 
      RefreshIndicator(
        onRefresh: getUserContacts,
        child: ListView.builder(
          itemCount:  _currentImage.length,
          itemBuilder: (BuildContext context, int index) {
            return titleSection(index);
            
          })) :
      Scaffold( // scaffold of the app
        body: Center(
        child: LoadingAnimationWidget.inkDrop( // LoadingAnimationwidget that call the
        color: Colors.blue,                          // staggereddotwave animation
        size: 50,
        ),
        ),
        ), 
      );
    }

Widget titleSection(index) { 
  return Column(
  children: [
    Container(
  
  padding: const EdgeInsets.all(10),
    child:
    Row(
      children:[ Text(_currentImage[index].subject,
          textAlign: TextAlign.start,
            style: GoogleFonts.rubik(
                color: Colors.black,
                fontSize: 14,
              ),
              
            ),
      ]
    ),
    ),
    CarouselSlider
    ( 
      items: _currentImage[index].attachmentpayload.map((image) {
    return Builder(
      builder: (BuildContext context) {
        return InteractiveViewer(
          minScale: 0.1,
          maxScale: 5.5,
          child: Image.memory(image,
                 width: 550,
	               height: 350,
                 fit: BoxFit.contain
                ),
      
        );
      },
    );
  }).toList(),
      //   ,
      
      
      options: CarouselOptions(height: 350, reverse: false,enableInfiniteScroll: false,  viewportFraction: 1

)
    ),
    
   
    Container(
  
  padding: const EdgeInsets.all(32),
  child: Row(
    children: [
      Expanded(
        /*1*/
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*2*/
            
            Container(
              padding: const EdgeInsets.only(bottom: 8,left: 0),
              child:  Text(
                _currentImage[index].content,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            Text(
             'from '+ _currentImage[index].from,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            Text(
              'date '+ _currentImage[index].date,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            Row(
              children: [
            Expanded(
              child:TextFormField(
              decoration: InputDecoration(
              hintText:'Enter User name here',
              ),
              onChanged: (value) {
                      setState(() {
                        inputValue = value;
                      });
                    },
              
            ),
            ),
            Padding(
          padding:  EdgeInsets.all(20.0),
            child: TextButton(
            
            style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
              onPressed: () {
                 
                sendMail(_currentUser.email,_currentheader,_currentImage[index],inputValue);

               },
              child: Text('Send'),
            )
            )

              ]
            ),
             Divider(
                       color: Colors.grey[500], //color of divider
                       height: 5, //height spacing of divider
                       thickness: 3, //thickness of divier line
                       indent: 1, //spacing at the start of divider
                       endIndent: 1, //spacing at the end of divider
                    ),
          ],
        ),
      ),
      /*3*/
     
    ],
  ),
  

  
),
  ]
);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: _currentUser == null
      //     ? Container()
      //     : FloatingActionButton(
      //         onPressed: () {
      //           try {
      //             _googleSignIn.signOut();
      //           } on Exception catch (e) {
      //             print(e);
      //           }
      //         },
      //         child: Icon(Icons.logout),
      //       ),
      appBar: AppBar(
    title: Text('X-Ray App'),
    actions: [
          IconButton(
              icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 25.0),
              onPressed: (){
                try {
                  _googleSignIn.signOut();
                } on Exception catch (e) {
                  print(e);
                }
              }
          ),
    ],
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          
          colors: <Color>[Color.fromARGB(255, 25, 105, 171), Color.fromARGB(255, 28, 134, 220)]),
      ),
    ),
  ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
          // child: isLoading
          //     ? Center(
          //         child: CircularProgressIndicator(),
          //       )
          child: _currentUser != null
                ? getContactListWidget()
                : getLoginWidget(),
        ),
    
    );
  }
}