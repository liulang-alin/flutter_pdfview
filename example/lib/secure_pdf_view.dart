// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import 'common_color.dart';
import 'string_util.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class SecurePdfView extends StatefulWidget {
  SecurePdfViewController controller;

  SecurePdfView(this.controller, {key}) : super(key: key);

  @override
  _SecurePdfViewState createState() => _SecurePdfViewState();
}

class PDFError {
  static const int passwordError = 100;
}

class CustomCacheManager {
  static const key = 'room_pdf_4';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 1),
      maxNrOfCacheObjects: 10,
    ),
  );
}

class _SecurePdfViewState extends State<SecurePdfView> {
  bool encrypted = false;
  String pdfPassword = "";
  bool waitingPwd = false;
  bool loading = true;
  GlobalKey<PdfPwdDialogState> dialogKey;
  GlobalKey<PdfPwdDialogState> pdfViewKey;
  String filePath;
  bool loadError = false;

  @override
  void initState() {
    super.initState();
    waitingPwd = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      CustomCacheManager.instance.getFileStream("https://examination-v3-1259785003.cos.ap-shanghai.myqcloud.com/dev/PyQt5%E5%BF%AB%E9%80%9F%E5%BC%80%E5%8F%91%E4%B8%8E%E5%AE%9E%E6%88%98.pdf",withProgress: true).asBroadcastStream().listen((event) {
        final bool loading = event is DownloadProgress;

        if (loading) {
          final double progress =
          (((event as DownloadProgress)?.progress ?? 0) * 100)
              .roundToDouble();
          print("loading = $loading  progress=$progress");
        } else {
          final String filePath = (event as FileInfo).file.path;
          print("loading = $loading  filePath=$filePath");
        }
      },onDone: (){
        print("onDone");
      },onError: (error){
        print("onError=$error");
      },cancelOnError: false);
      // CustomCacheManager.instance.getSingleFile("https://examination-v3-1259785003.cos.ap-shanghai.myqcloud.com/dev/PyQt5%E5%BF%AB%E9%80%9F%E5%BC%80%E5%8F%91%E4%B8%8E%E5%AE%9E%E6%88%98.pdf").then((value){
      //   filePath = value.path;
      //   loading = false;
      //   setState(() {
      //
      //   });
      // }).catchError((error){
      //   loading = false;
      //   loadError = true;
      //   setState(() {
      //
      //   });
      // });
    });
  }

  @override
  void dispose() {
    dialogKey?.currentState?.exitDialog();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(loading){
      return Text("加载中...");
    }else{
      if(loadError || StringUtil.isEmpty(filePath)){
        return Text("加载错误...");
      }
    }
    if(waitingPwd){
      bool isError = encrypted&&StringUtil.isNotEmpty(pdfPassword);
      return Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isError?"密码错误":"",style: TextStyle(fontSize: 28,color: isError?CommonColor.textRed:CommonColor.textTip),),
              SizedBox(height: 24),
              TextButton(
                onPressed: (){
                  dialogKey = GlobalKey<PdfPwdDialogState>();
                  showDialog(context: context, builder: (ctx){
                    return PdfPwdDialog(
                      key: dialogKey,
                      sureCallback: (pwd){
                        waitingPwd = false;
                        refresh(true, pwd);
                      },);
                  });
                },
                child: Text("请输入密码",style: TextStyle(fontSize: 28,color: CommonColor.textTip),),
              ),
            ],
          )
        ),
      );
    }
    return PDFView(
      password: pdfPassword,
      filePath: filePath,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: false,
      pageFling: false,
      pageSnap: false,
      // defaultPage: currentPage!,
      fitPolicy: FitPolicy.WIDTH,
      preventLinkNavigation:false, // if set to true the link is handled in flutter
      onRender: (_pages) {
      },
      onError: (error) {
        int code = error['code']??0;
        String msg = error['errorMsg']??"".toLowerCase();
        if(code==100 || msg.contains("Password required or incorrect password".toLowerCase())){
          setState(() {
            waitingPwd = true;
          });
        }else{
          setState(() {
            // loadError
          });
        }
      },
      onPageError: (page, error) {
      },
      onViewCreated: (PDFViewController pdfViewController) {
      },
      onLinkHandler: (String uri) {
        print('goto uri: $uri');
      },
      onPageChanged: (int page, int total) {
      },
    );
  }

  void refresh(bool encrypted, String password) {
    setState(() {
      this.encrypted = encrypted;
      pdfPassword = password;
    });
  }
}

class SecurePdfViewController extends ChangeNotifier {
  String pdf = "";
  bool isUrl = false;

  SecurePdfViewController({this.pdf, this.isUrl});

  static SecurePdfViewController network(String url) {
    return SecurePdfViewController(pdf: url, isUrl: true);
  }

  static SecurePdfViewController path(String path) {
    return SecurePdfViewController(pdf: path, isUrl: false);
  }

  void changePdfWithUrl(String url) {
    pdf = url;
    isUrl = true;
  }

  void changePdfWithPath(String path) {
    pdf = path;
    isUrl = false;
  }
}




class PdfPwdDialog extends StatefulWidget {
  final ValueChanged<String> sureCallback;
  const PdfPwdDialog({Key key,this.sureCallback}) : super(key: key);

  @override
  PdfPwdDialogState createState() => PdfPwdDialogState();
}

class PdfPwdDialogState extends State<PdfPwdDialog> {
  TextEditingController controller;
  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  void exitDialog(){
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 50),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(4)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16,horizontal: 12),
                child: Text(
                  "请输入正确密码",
                  style: TextStyle(
                      color: Color(0xff192038),
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  showCursor: true,
                  controller: controller,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: '输入密码'),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 49,
                      child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            child: const Text(
                              "取消",
                              style: TextStyle(
                                color: Color(0xff434B61),
                                fontSize: 16,
                              ),
                            ),
                          )),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 49,
                      child: TextButton(
                          onPressed: () {
                            String text = controller?.text??"";
                            if(StringUtil.isNotEmpty(text)){
                              Navigator.of(context).pop(true);
                              widget.sureCallback?.call(text);
                            }else{
                            }
                          },
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            child: const Text(
                              "确定",
                              style: TextStyle(
                                color: Color(0xff3949AB),
                                fontSize: 16,
                              ),
                            ),
                          )),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
