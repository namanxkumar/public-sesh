import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:testproj/util/firestore.dart';
import 'package:testproj/util/models.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key, required this.user}) : super(key: key);
  final UserModel user;

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  late TextEditingController controller1;
  late TextEditingController controller2s;
  late TextEditingController controller2d;
  late TextEditingController controller2e;
  var color;
  void initState() {
    controller1 = TextEditingController(text: widget.user.displayname);
    controller2s =
        TextEditingController(text: widget.user.foreigntags["steam"]);
    controller2d =
        TextEditingController(text: widget.user.foreigntags["discord"]);
    controller2e = TextEditingController(text: widget.user.foreigntags["epic"]);
    color = widget.user.color;

    super.initState();
  }

  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();

  onSubmit() {
    if (formKey1.currentState!.validate() &&
        formKey2.currentState!.validate()) {
      print("Valid");
      var display = controller1.text.trim();
      var discord = controller2d.text.trim();
      var steam = controller2s.text.trim();
      var epic = controller2e.text.trim();
      FirestoreService()
          .updateBasicProfile(color, display, discord, steam, epic);
      Navigator.pop(context);
    }
  }

  onSelectColor(color) {
    this.color = color;
    print(this.color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      PictureColorSection(
                          color: color, onSelect: onSelectColor),
                      SizedBox(height: 8),
                      EditNameSection(
                          controller: controller1, formkey: formKey1),
                      EditForeignSection(
                        controller2d: controller2d,
                        controller2e: controller2e,
                        controller2s: controller2s,
                        formkey: formKey2,
                      ),
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

class EditForeignSection extends StatefulWidget {
  const EditForeignSection(
      {Key? key,
      required this.controller2d,
      required this.controller2e,
      required this.controller2s,
      required this.formkey})
      : super(key: key);
  final controller2d;
  final controller2s;
  final controller2e;
  final formkey;

  @override
  _EditForeignSectionState createState() => _EditForeignSectionState();
}

class _EditForeignSectionState extends State<EditForeignSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: widget.formkey,
        child: Column(
          children: [
            TextFormField(
              controller: widget.controller2d,
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 18.0,
              ),
              decoration: InputDecoration(
                labelText: "DISCORD",
                hintText: "username#0000",
                labelStyle: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
                alignLabelWithHint: true,
                fillColor: Color(0xff181818),
                hintStyle: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                ),
                errorStyle: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.primary),
                border: InputBorder.none,
              ),
              cursorColor: Theme.of(context).colorScheme.primary,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
            ),
            TextFormField(
              controller: widget.controller2s,
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 18.0,
              ),
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: "STEAM",
                hintText: "username",
                labelStyle: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
                fillColor: Color(0xff181818),
                hintStyle: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                ),
                errorStyle: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.primary),
                border: InputBorder.none,
              ),
              cursorColor: Theme.of(context).colorScheme.primary,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
            ),
            TextFormField(
              controller: widget.controller2e,
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 18.0,
              ),
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: "EPIC GAMES",
                hintText: "username",
                labelStyle: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
                fillColor: Color(0xff181818),
                hintStyle: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                ),
                errorStyle: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.primary),
                border: InputBorder.none,
              ),
              cursorColor: Theme.of(context).colorScheme.primary,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
            ),
          ],
        ),
      ),
    );
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
              return 'Enter a display name';
            } else if (value.length >= 26) {
              return 'Display name cannot be longer than 26 characters';
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
            labelText: "DISPLAY NAME",
            labelStyle: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
            ),
            fillColor: Color(0xff181818),
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

class PictureColorSection extends StatefulWidget {
  const PictureColorSection(
      {Key? key, required this.color, required this.onSelect})
      : super(key: key);
  final color;
  final onSelect;

  @override
  _PictureColorSectionState createState() => _PictureColorSectionState();
}

class _PictureColorSectionState extends State<PictureColorSection> {
  final colors = [0xffE9CE2C, 0xff4BB3FD, 0xffCA6BC0, 0xff602AB8, 0xffE85C5C];
  var _currentIndex;
  @override
  void initState() {
    _currentIndex = colors.indexOf(widget.color);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(90),
          ),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage:
                  NetworkImage("https://placedog.net/500/500?random"),
              // child: Stack(
              //   children: [
              //     Container(
              //       decoration: BoxDecoration(
              //           color: Color.fromRGBO(0, 0, 0, 0.5),
              //           borderRadius: BorderRadius.circular(90)),
              //     ),
              //   ],
              // ),
              radius: 48.5,
            ),
          ),
        ),
        SizedBox(
          width: 4,
        ),
        Expanded(
          child: Container(
            height: 100,
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: colors.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                      widget.onSelect(colors[index]);
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 3),
                    decoration: _currentIndex == index
                        ? BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary),
                            shape: BoxShape.circle)
                        : BoxDecoration(),
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(colors[index]),
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(
                          height: 35,
                          width: 35,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
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
