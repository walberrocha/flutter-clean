import 'package:flutter/material.dart';

import '../../components/components.dart';
import 'login_presenter.dart';

class LoginPage extends StatefulWidget {
  final LoginPresenter? presenter;

  const LoginPage(this.presenter);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  void dispose() {
    super.dispose();
    widget.presenter!.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          widget.presenter!.isLoadingStream.listen(
            (isLoading) {
              if (isLoading == true) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return SimpleDialog(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(),
                              SizedBox(height: 10),
                              Text(
                                'Aguarde ...',
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ],
                      );
                    });
              } else {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
              }
            },
          );

          widget.presenter!.mainErrorController.listen((error) {
            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  error,
                  textAlign: TextAlign.center,
                ),
                backgroundColor: Colors.red[900],
              ));
            }
          });

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LoginHeader(),
                const HeadLine1(
                  text: 'entrar',
                ),
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                      child: Column(
                    children: [
                      StreamBuilder<String?>(
                          stream: widget.presenter!.emailErrorStream,
                          builder: (context, snapshot) {
                            return TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email',
                                icon: Icon(
                                  Icons.email,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                errorText: snapshot.data?.isEmpty == true
                                    ? null
                                    : snapshot.data,
                              ),
                              onChanged: widget.presenter!.validateEmail,
                              keyboardType: TextInputType.emailAddress,
                            );
                          }),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 32),
                        child: StreamBuilder<String?>(
                            stream: widget.presenter!.passwordErrorStream,
                            builder: (context, snapshot) {
                              return TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  icon: Icon(Icons.lock,
                                      color:
                                          Theme.of(context).primaryColorLight),
                                  errorText: snapshot.data?.isEmpty == true
                                      ? null
                                      : snapshot.data,
                                ),
                                obscureText: true,
                                onChanged: widget.presenter!.validatePassword,
                              );
                            }),
                      ),
                      StreamBuilder<bool?>(
                          stream: widget.presenter!.isFormValidController,
                          builder: (context, snapshot) {
                            return ElevatedButton(
                              onPressed: snapshot.data == true
                                  ? widget.presenter!.auth
                                  : null,
                              child: Text('Entrar'.toUpperCase()),
                            );
                          }),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.person),
                      ),
                    ],
                  )),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}