import 'package:flutter/material.dart';
import 'package:flutter_pdfview_example/secure_pdf_view.dart';

class YKCPdfPage extends StatefulWidget {
  String path;

  YKCPdfPage(this.path);

  @override
  _YKCPdfPageState createState() => _YKCPdfPageState();
}

class _YKCPdfPageState extends State<YKCPdfPage> {
  bool isExpanded = true;
  SecurePdfViewController pdfViewController;

  @override
  void initState() {
    // pdfViewController = SecurePdfViewController.path(widget.path);
    pdfViewController = SecurePdfViewController.network("https://examination-v3-1259785003.cos.ap-shanghai.myqcloud.com/test/company/16401851220008418.531614921818/pdf%E5%B1%95%E7%A4%BA%E4%B8%8D%E5%87%BA%E6%9D%A5%E7%9A%84%E5%8D%B7%E5%AD%90.pdf");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("pdf测试"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: isExpanded ? 200 : 100,
            child: Transform.scale(
              scale: isExpanded ? 1 : 0.5,
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.yellow,
                child: TextButton(
                  child: Text("切换"),
                  onPressed: (){
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: SecurePdfView(pdfViewController)??Center(child: Container(color: Colors.red,height: 20,width: 20,),),
          )
        ],
      ),
    );
  }
}
