import 'package:flutter/material.dart';

class DownloadSignScreen extends StatelessWidget {
  const DownloadSignScreen({super.key});

  static const Color brandYellow = Color(0xFFFFD400);

  // ----------------------------------------------------------------------
  // POPUP FUNCTION
  // ----------------------------------------------------------------------
  void openDownloadPopup(
      BuildContext context, String packTitle, int totalMB, List<Map<String, dynamic>> items) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // -------- TITLE --------
                Text(
                  "Total Pack",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  "$totalMB MB",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 14),

                // -------- LIST OF ITEMS --------
                SizedBox(
                  height: 260,
                  child: ListView(
                    children: items.map((item) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            // NAME
                            Expanded(
                              child: Text(
                                "${item["name"]} • ${item["size"]}MB",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            // DOWNLOAD ICON
                            const Icon(Icons.download, size: 26),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 18),

                // -------- DOWNLOAD ALL BUTTON --------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      "Download All",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  // SMALL OPTION BOX (CLICKABLE)
  // ----------------------------------------------------------------------
  Widget smallOption(
      BuildContext context,
      String text,
      int totalSize,
      List<Map<String, dynamic>> items,
      ) {
    return GestureDetector(
      onTap: () {
        openDownloadPopup(context, text, totalSize, items);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white, // clean white small box
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // BIG BOX (SCROLLABLE CATEGORY)
  // ----------------------------------------------------------------------
  Widget bigBox(
      BuildContext context, String heading, List<String> options) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7), // ✔️ light grey background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 230,
            child: ListView(
              children: [
                for (var item in options)
                  smallOption(
                    context,
                    item,
                    150, // total MB
                    [
                      {"name": "Hello", "size": 5},
                      {"name": "Thank You", "size": 7},
                      {"name": "Good Morning", "size": 9},
                      {"name": "I Love You", "size": 8},
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // DOWNLOAD BOXES WITH LIGHT COLOR
  // ----------------------------------------------------------------------
  Widget downloadBox(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FA), // ✔️ soft blue-grey
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                "Show Info",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // MAIN SCREEN
  // ----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: brandYellow,
        elevation: 0,
        title: const Text(
          "Your SignAnimations",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            bigBox(context, "Animations", [
              "15 Animations",
              "25 Animations",
              "50 Animations",
              "70 Animations",
              "100 Animations",
            ]),

            bigBox(context, "Signs", [
              "20 Signs",
              "40 Signs",
              "60 Signs",
              "80 Signs",
              "100 Signs",
            ]),

            const SizedBox(height: 12),

            downloadBox("Download Pack 1"),
            downloadBox("Download Pack 2"),
            downloadBox("Download Pack 3"),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
