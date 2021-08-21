import 'dart:math';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/models/provider_auth.dart';
import 'package:shop_app/models/httpException.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const id = 'auth_screen';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 70.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)..translate(-5.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'Stars Shop',
                        style: TextStyle(
                          color: Theme.of(context).accentTextTheme.headline6.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  //Animation Stuff
  AnimationController _animController;
  Animation<double> _heightAnimation;
  Animation<double> _opacityAnimation;
  Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _heightAnimation = Tween<double>(
      begin: 260,
      end: 320,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.fastOutSlowIn),
    );

    //For manual Animation , you need to configure animation manually
    // _heightAnimation.addListener(() => setState(() {}));
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, -1.5), end: Offset(0, 0)).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.fastOutSlowIn,
      ),
    );
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _animController.dispose();
  // }

  void _showDialog(String eMessage) {
    showDialog(
      context: context,
      builder: (bCtx) => AlertDialog(
        title: Text('Error!'),
        content: Text(eMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(bCtx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    //Start Loading Spinner
    setState(() {
      _isLoading = true;
    });

    //For Firebase Flutter Authentication along with errorHandling
    // try {
    //   if (_authMode == AuthMode.Login) {
    //     // Log user in
    //     await Provider.of<Auth>(context, listen: false).flutterFirebaseSignIn(
    //       _authData['email'],
    //       _authData['password'],
    //     );
    //   } else {
    //     // Sign user up
    //     await Provider.of<Auth>(context, listen: false).flutterFirebaseSignUp(
    //       _authData['email'],
    //       _authData['password'],
    //     );
    //   }
    // } on HttpException catch (error) {
    //   String eMessage = error.toString();
    //   if (eMessage.contains('weak-password')) {
    //     eMessage = 'The password provided is too weak.';
    //   } else if (eMessage.contains('email-already-in-use')) {
    //     eMessage = 'There is an account already exists for that email.';
    //   } else if (eMessage.contains('user-not-found')) {
    //     eMessage = 'No user found for that email.';
    //   } else if (eMessage.contains('wrong-password')) {
    //     eMessage = 'Wrong password provided for that user.';
    //   }
    //   _showDialog(eMessage);
    // } catch (error) {
    //   const eMessage = 'Check your Network Connection!';
    //   _showDialog(eMessage);
    // }

    //For Firebase REST Authentication API
    try {
      //SignUp
      if (_authMode == AuthMode.Signup) {
        await Provider.of<Auth>(context, listen: false)
            .firebaseRESTSignUp(
              _authData['email'],
              _authData['password'],
            )
            .then(
              (value) {},
            );
      }
      //SignIn
      else {
        await Provider.of<Auth>(context, listen: false)
            .firebaseRESTSignIn(
              _authData['email'],
              _authData['password'],
            )
            .then(
              (value) {},
            );
      }
    } on HttpException catch (error) {
      var errorMessage = error.toString();
      if (errorMessage.contains('EMAIL_EXISTS')) {
        errorMessage = 'This Email address is already in use!';
      } else if (errorMessage.contains('OPERATION_NOT_ALLOWED')) {
        errorMessage = 'You Can\'t sign in at the moment!';
      } else if (errorMessage.contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
        errorMessage = 'You have been temporary blocked for sending too many requests , try again later.';
      } else if (errorMessage.contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'No such email exists!';
      } else if (errorMessage.contains('INVALID_PASSWORD')) {
        errorMessage = 'Wrong Password!';
      } else if (errorMessage.contains('USER_DISABLED')) {
        errorMessage = 'Your Account has been disabled!';
      }
      _showDialog(errorMessage);
    } catch (error) {
      var errorMessage = 'Couldn\'t Authenticate You , Check your '
          'Network connection and try again later.';
      _showDialog(errorMessage);
    }

    //Stop Loading Spinner
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _animController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.Signup ? 320 : 260,
        // height: _heightAnimation.value.height,
        constraints: BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        // constraints: BoxConstraints(minHeight: _heightAnimation.value.height),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                  textInputAction: TextInputAction.next,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                  textInputAction: TextInputAction.next,
                ),
                if (_authMode == AuthMode.Signup)
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: TextFormField(
                      enabled: _authMode == AuthMode.Signup,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match!';
                              } else {
                                return null;
                              }
                            }
                          : null,
                    ),
                  ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child: Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child: Text('${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
