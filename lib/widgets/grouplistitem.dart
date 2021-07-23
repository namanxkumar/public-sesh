import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class ListItem extends StatelessWidget {
  ListItem(this.nmembers, this.group, this.creator);

  final int nmembers;
  final String group;
  final String creator;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Container(
              width: 260,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.transparent,
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black,
                //     offset: const Offset(0, 1),
                //     blurRadius: 2.0,
                //   )
                // ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        group,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      nmembers.toString(),
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        creator == FirebaseAuth.instance.currentUser!.uid
            ? Padding(
                padding: const EdgeInsets.only(bottom: 15.0, left: 15.0),
                child: Container(
                  height: 50,
                  width: 50,
                  child: EditButton(),
                ),
              )
            : Container(),
      ],
    );
  }
}

class EditButton extends StatelessWidget {
  // final onTodayPress;
  // GreenButton(this.onTodayPress);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            LineIcons.pen,
            size: 26,
            color: Theme.of(context).colorScheme.primary,
          ),
          // splashColor: Color(0xff000000),
          onTap: () {},
        ),
      ),
    );
  }
}
