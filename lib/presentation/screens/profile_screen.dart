import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/business/profile/profile_cubit.dart';
import 'package:chat_app/core/constants/routes.dart';
import 'package:chat_app/data/api/api_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/helper/dialogs.dart';
import '../../core/media_query.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final formKey = GlobalKey<FormState>();
  var name = "";
  var about = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      BlocProvider.of<ProfileCubit>(context, listen: false).getTheCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Your Profile"),
          centerTitle: true,
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is UpdateProfileInfoLoadingState) {
              Dialogs.showLoadingDialog(context);
            } else if (state is UpdateProfileInfoSuccessState) {
              Navigator.pop(context);
              Dialogs.showSuccessSnackBar(
                  context, "Profile Updated Successfully !!");
              context.read<ProfileCubit>().getTheCurrentUser();
            } else if (state is PickImageState) {
              Navigator.pop(context);
            } else if (state is UpdateProfileInfoSuccessState) {
              Dialogs.showSuccessSnackBar(
                  context, "Your Profile Picture update successfully");
              context.read<ProfileCubit>().getTheCurrentUser();
            }
          },
          builder: (context, state) {
            switch (state.runtimeType) {
              case ProfileInfoLoadingState:
              case UpdateProfileInfoLoadingState:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ProfileInfoErrorState:
                return const Center(
                  child: Text(
                    "Error Occured while fetching your information !!",
                  ),
                );
              case LoadImageToFirebaseStoreErrorState:
                return const Center(
                  child: Text(
                    "Error Occured while upload your image !!",
                  ),
                );
              case ProfileInfoSuccessState:
              case UpdateProfileInfoSuccessState:
              case PickImageState:
              case LoadImageToFirebaseStoreSuccessState:
                return Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: mediaQuery(context).height * 0.06,
                          ),
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              context.read<ProfileCubit>().image == null

                                  /// Get the image from the firebase
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          mediaQuery(context).height * 0.1),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        width: mediaQuery(context).height * 0.2,
                                        height:
                                            mediaQuery(context).height * 0.2,
                                        imageUrl: ApiServices.user!.photoURL!,
                                        placeholder: (_, s) =>
                                            const CircleAvatar(
                                          child:
                                              Icon(CupertinoIcons.person_2_alt),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const CircleAvatar(
                                          child:
                                              Icon(CupertinoIcons.person_2_alt),
                                        ),
                                      ),
                                    )

                                  /// Selected Image from gallery or camera
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          mediaQuery(context).height * 0.1),
                                      child: Image.file(
                                        File(context
                                            .read<ProfileCubit>()
                                            .image!),
                                        fit: BoxFit.fill,
                                        width: mediaQuery(context).height * 0.2,
                                        height:
                                            mediaQuery(context).height * 0.2,
                                      ),
                                    ),
                              Positioned(
                                bottom: -1,
                                right: -20,
                                child: MaterialButton(
                                  color: Colors.white,
                                  shape: const CircleBorder(),
                                  elevation: 2,
                                  onPressed: () {
                                    _showPickImageModalBottomSheet(context);
                                  },
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: mediaQuery(context).height * 0.02,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              ApiServices.user!.email!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: mediaQuery(context).height * 0.08,
                          ),
                          TextFormField(
                            initialValue:
                                context.read<ProfileCubit>().currentUser!.name,
                            onSaved: (value) => name = value!,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Required Name";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person),
                                prefixIconColor: Colors.blueAccent,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                hintText: "eg. Omar Gomaa",
                                label: const Text("Name")),
                          ),
                          SizedBox(
                            height: mediaQuery(context).height * 0.025,
                          ),
                          TextFormField(
                            onSaved: (value) => about = value!,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Required About";
                              }
                              return null;
                            },
                            initialValue:
                                context.read<ProfileCubit>().currentUser!.about,
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.info_outline),
                                prefixIconColor: Colors.blueAccent,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                hintText: "eg. I am Happy !!",
                                label: const Text("About")),
                          ),
                          SizedBox(
                            height: mediaQuery(context).height * 0.03,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();
                                context
                                    .read<ProfileCubit>()
                                    .updateUserInfo(name, about);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              minimumSize: Size(mediaQuery(context).width * .4,
                                  mediaQuery(context).height * .055),
                            ),
                            icon: const Icon(Icons.edit),
                            label: const Text(
                              "Edit",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              default:
                return const SizedBox.shrink();
            }
          },
        ),
        floatingActionButton: BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is SignOutLoadingState) {
              Dialogs.showLoadingDialog(context);
            } else if (state is SignOutErrorState) {
              Navigator.pop(context);
              Dialogs.showErrorSnackBar(context);
            } else if (state is SignOutSuccessState) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.loginScreenRoute,
                (Route<dynamic> route) => false,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 8),
            child: Builder(builder: (context) {
              return FloatingActionButton.extended(
                onPressed: () async {
                  await context.read<ProfileCubit>().signOut(context);
                },
                label: const Text("Logout"),
                icon: const Icon(Icons.logout),
                backgroundColor: Colors.red,
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showPickImageModalBottomSheet(BuildContext receivedContext) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(
                vertical: mediaQuery(context).height * 0.05),
            children: [
              const Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.white,
                        fixedSize: Size(
                          mediaQuery(context).width * 0.3,
                          mediaQuery(context).height * 0.15,
                        )),
                    onPressed: () async {
                      await BlocProvider.of<ProfileCubit>(receivedContext,
                              listen: false)
                          .pickImage(ImageSource.camera);
                    },
                    child: Image.asset("assets/images/camera.png"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.white,
                        fixedSize: Size(
                          mediaQuery(context).width * 0.3,
                          mediaQuery(context).height * 0.15,
                        )),
                    onPressed: () async {
                      await BlocProvider.of<ProfileCubit>(receivedContext,
                              listen: false)
                          .pickImage(ImageSource.gallery);
                    },
                    child: Image.asset("assets/images/gallery.png"),
                  )
                ],
              ),
            ],
          );
        });
  }
}
