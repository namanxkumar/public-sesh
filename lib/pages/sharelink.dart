import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testproj/util/firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

class ShareLink extends StatefulWidget {
  const ShareLink({Key? key, required this.gid, required this.link})
      : super(key: key);
  final gid;
  final link;

  @override
  _ShareLinkState createState() => _ShareLinkState();
}

class _ShareLinkState extends State<ShareLink> {
  String? _linkMessage;
  bool _isCreatingLink = false;
  var link;
  initState() {
    link = widget.link;
    super.initState();
  }

  Future<void> _createDynamicLink(bool short) async {
    setState(() {
      _isCreatingLink = true;
    });
    var uuid = Uuid();
    var pagelink = uuid.v4();
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://sesher.page.link',
      link: Uri.parse(
          'https://sesh.gg/joingroup?id=${widget.gid}&&linkid=${pagelink}'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.sesh',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.example.sesh',
        minimumVersion: '0',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
    } else {
      url = await parameters.buildUrl();
    }

    var linkid = await FirestoreService()
        .updateGroupLink(pagelink, url.toString(), widget.gid);
    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
      link = _linkMessage;
    });
    print(_linkMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 28, right: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(),
              Row(
                children: [
                  LinkSection(link),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  _createDynamicLink(true);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.only(
                      top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                  primary: Theme.of(context).colorScheme.primaryVariant,
                  onPrimary: Theme.of(context).colorScheme.primary,
                  textStyle: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                  ),
                ),
                child: _isCreatingLink ? Text("Loading...") : Text("New Link"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
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
                    "Invite Link",
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

class LinkSection extends StatelessWidget {
  final link;
  LinkSection(this.link);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: link == ""
            ? [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "LINK",
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Create a new link",
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ]
            : [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "LINK",
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${link}",
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextButton.icon(
                    icon: Icon(
                      Icons.content_copy,
                      size: 16,
                    ),
                    style: TextButton.styleFrom(
                        primary: Theme.of(context).colorScheme.onSurface,
                        textStyle: GoogleFonts.poppins(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        )),
                    label: Text('Copy'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link)).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Link copied to clipboard")));
                      });
                    },
                  ),
                ),
              ],
      )),
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
