import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:testproj/homepage.dart';
import 'package:testproj/util/firestore.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({Key? key}) : super(key: key);

  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  late TextEditingController controller1;
  late TextEditingController controller2;
  initState() {
    controller1 = TextEditingController();
    controller2 = TextEditingController();
    super.initState();
  }

  var loader = 0;
  onSubmit() async {
    if (formKey2.currentState!.validate() &&
        formKey1.currentState!.validate()) {
      setState(() {
        loader = 1;
      });
      var ret = await FirestoreService()
          .createGroup(controller1.text.trim(), controller2.text.trim());
      var snackbar = SnackBar(
          content: Text("${ret[1]}"),
          // padding: EdgeInsets.all(8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          backgroundColor: Theme.of(context).colorScheme.surface);
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Navigator.pop(context);
    }
  }

  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return loader == 1
        ? Loader()
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 28, right: 28),
                child: Column(
                  children: [
                    CustomAppBar(onSubmit: onSubmit),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            EditNameSection(
                                controller: controller1, formkey: formKey1),
                            EditDescriptionSection(
                                controller: controller2, formkey: formKey2),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ));
  }
}

class EditNameSection extends StatefulWidget {
  const EditNameSection(
      {Key? key, required this.controller, required this.formkey})
      : super(key: key);
  final controller;
  final formkey;

  @override
  _EditNameSectionState createState() => _EditNameSectionState();
}

class _EditNameSectionState extends State<EditNameSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: widget.formkey,
        child: TextFormField(
          controller: widget.controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter a group name';
            } else if (value.length >= 26) {
              return 'Name cannot be longer than 26 characters';
            }
            return null;
          },
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
            fontSize: 20.0,
          ),
          decoration: InputDecoration(
            alignLabelWithHint: true,
            labelText: "NAME",
            labelStyle: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
            ),
            fillColor: Color(0xff181818),
            hintText: "Name your group",
            hintStyle: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 20.0,
            ),
            errorStyle: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.primary),
            border: InputBorder.none,
          ),
          cursorColor: Theme.of(context).colorScheme.primary,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
        ),
      ),
    );
  }
}

class EditDescriptionSection extends StatefulWidget {
  const EditDescriptionSection(
      {Key? key, required this.controller, required this.formkey})
      : super(key: key);
  final controller;
  final formkey;

  @override
  _EditDescriptionSectionState createState() => _EditDescriptionSectionState();
}

class _EditDescriptionSectionState extends State<EditDescriptionSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: widget.formkey,
        child: TextFormField(
          controller: widget.controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter a description';
            } else if (value.length >= 140) {
              return 'Name cannot be longer than 140 characters';
            }
            return null;
          },
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
            fontSize: 20.0,
          ),
          decoration: InputDecoration(
            alignLabelWithHint: true,
            labelText: "DESCRIPTION",
            labelStyle: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
            ),
            fillColor: Color(0xff181818),
            hintText: "Add a description",
            hintStyle: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 20.0,
            ),
            errorStyle: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.primary),
            border: InputBorder.none,
          ),
          cursorColor: Theme.of(context).colorScheme.primary,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final onSubmit;
  CustomAppBar({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  BackButton(),
                  Text(
                    "Edit Profile",
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              CheckButton(onSubmit)
            ],
          ),
        ],
      ),
    );
  }
}

class BackButton extends StatelessWidget {
  // final onTodayPress;
  // GreenButton(this.onTodayPress);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.only(right: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 22,
              color: Theme.of(context).colorScheme.primary,
            ),
            // splashColor: Color(0xff000000),
          ),
        ),
      ),
    );
  }
}

class CheckButton extends StatelessWidget {
  final onSubmit;
  CheckButton(this.onSubmit);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47.0,
      width: 47.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Theme.of(context).colorScheme.primaryVariant,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            // customBorder: ,
            child: Icon(
              Icons.check,
              size: 26,
              color: Theme.of(context).colorScheme.primary,
            ),
            // splashColor: Color(0xff000000),
            onTap: () {
              onSubmit();
            },
          ),
        ),
      ),
    );
  }
}
