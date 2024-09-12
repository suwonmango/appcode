import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/model_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// TabFit이라는 StatefulWidget을 정의합니다. isMultiSelectMode를 통해 여러 이미지를 선택할 수 있는지 설정할 수 있습니다.
class TabFit extends StatefulWidget {
  final bool isMultiSelectMode;

  TabFit({this.isMultiSelectMode = false});

  @override
  _TabFitState createState() => _TabFitState();
}

// _TabFitState 클래스는 TabFit의 상태를 관리합니다.
class _TabFitState extends State<TabFit> {
  // 피팅 화면과 관련된 코드
  Map<String, String> _selectedHashtags = {};  // 선택된 해시태그들을 저장하는 Set

  final Map<String, String> hashtagTranslations = {
    // 성별
    "#여성": "A woman",
    "#남성": "A man",

    // 키
    "#아주작은(150cm 이하)": "very short (under 150cm)",
    "#작은(150-160cm)": "short (150-160cm)",
    "#보통(160-170cm)": "average height (160-170cm)",
    "#큰(170-180cm)": "tall (170-180cm)",
    "#아주큰(180cm 이상)": "very tall (above 180cm)",

    //비율
    "#다리긴": "with long legs",
    "#상체긴": "with a long torso",
    "#비율균형": "with balanced proportions",

    // 체중
    "#매우마름": "very slim",
    "#마름": "slim",
    "#보통": "average weight",
    "#약간통통": "slightly chubby",
    "#통통": "chubby",
    "#근육형": "muscular",

    // 피부색
    "#밝은피부": "with fair skin",
    "#보통피부": "with medium skin",
    "#어두운피부": "with dark skin",
    "#황색톤피부": "with yellow-toned skin",
    "#핑크톤피부": "with pink-toned skin",

    // 신체 특징
    "#넓은어깨": "with broad shoulders",
    "#좁은어깨": "with narrow shoulders",
    "#큰가슴": "with a large bust",
    "#작은가슴": "with a small bust",
    "#허리잘록": "with a narrow waist",
    "#허리넓은": "with a wide waist",
    "#엉덩이큰": "with large hips",
    "#엉덩이작은": "with small hips",
    "#팔길쭉": "with long arms",
    "#다리길쭉": "with long legs",

    // 연령대
    "#10대": "in teens",
    "#20대": "in 20s",
    "#30대": "in 30s",
    "#40대": "in 40s",
    "#50대이상": "in 50s or older"
  };


  // 카테고리와 해시태그를 매핑하는 맵
  final Map<String, List<String>> categories = {
    "성별": ["#여성", "#남성"],
    "키": ["#아주작은(150cm 이하)", "#작은(150-160cm)", "#보통(160-170cm)", "#큰(170-180cm)", "#아주큰(180cm 이상)"],
    "비율": ["#다리긴", "#상체긴", "#비율균형"],
    "체중": ["#매우마름", "#마름", "#보통", "#약간통통", "#통통", "#근육형"],
    "특징적인 신체 부분": ["#넓은어깨", "#좁은어깨", "#큰가슴", "#작은가슴", "#허리잘록", "#허리넓은", "#엉덩이큰", "#엉덩이작은", "#팔길쭉", "#다리길쭉"],
    "피부색": ["#밝은피부", "#보통피부", "#어두운피부", "#황색톤피부", "#핑크톤피부"],
    "연령대": ["#10대", "#20대", "#30대", "#40대", "#50대이상"]
  };

  // 해시태그를 기반으로 프롬프트 문장을 생성하는 함수
  String _generatePrompt() {
    String gender = hashtagTranslations[_selectedHashtags["성별"]] ?? "";  // null이면 빈 문자열
    String age = hashtagTranslations[_selectedHashtags["연령대"]] != null ? " ${hashtagTranslations[_selectedHashtags["연령대"]]}" : "";
    String height = hashtagTranslations[_selectedHashtags["키"]] ?? "";  // 키 항목
    String proportion = hashtagTranslations[_selectedHashtags["비율"]] ?? "";  // 비율 항목
    String weight = hashtagTranslations[_selectedHashtags["체중"]] ?? "";  // null이면 빈 문자열
    String skinTone = hashtagTranslations[_selectedHashtags["피부색"]] != null ? "${hashtagTranslations[_selectedHashtags["피부색"]]}" : "";
    String bodyFeature = hashtagTranslations[_selectedHashtags["특징적인 신체 부분"]] != null ? " and ${hashtagTranslations[_selectedHashtags["특징적인 신체 부분"]]}" : "";

    return "$gender$age who is $height, $weight $proportion $skinTone $bodyFeature.";
  }



  // 해시태그를 선택하는 로직 (카테고리당 하나의 해시태그만 선택 가능)
  void _onHashtagSelected(String category, String hashtag) {
    setState(() {
      _selectedHashtags[category] = hashtag;
    });
    print("Selected category: $category, hashtag: $hashtag");  // 선택된 해시태그 디버깅용 로그
  }

  Widget _buildFitScreen() {
    return Column(
      children: [
        Expanded(child: HashtagSelector(categories: categories, selectedHashtags: _selectedHashtags, onHashtagSelected: _onHashtagSelected)),  // 해시태그 선택 위젯
        Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: ShapeDecoration(
            color: Color(0xFFF9C63D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: TextButton(
            onPressed: () {
              // 모델 생성 버튼 클릭 시 프롬프트 출력
              String prompt = _generatePrompt();
              print(prompt);  // 프롬프트 출력 (혹은 다음 화면에 넘길 수 있음)
              // Navigator.pushNamed(context, '/screen_modelCreate', arguments: prompt);
            },
            child: Center(
              child: Text(
                '모델 생성',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF7F9FC),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 0.11,
                  letterSpacing: 0.21,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 나의 옷장 화면과 관련된 코드
  final ImagePicker _imagePicker = ImagePicker();  // 이미지를 선택하기 위한 ImagePicker 객체 생성
  List<WardrobeItem> _wardrobeItems = [];  // 옷장에 있는 아이템 목록을 저장하는 리스트
  User? currentUser;  // 현재 로그인된 유저 정보를 저장할 변수
  List<String> _selectedImageUrls = [];  // 선택된 이미지 URL들을 저장하는 리스트 (멀티 선택 모드에서 사용)
  bool _isLoading = false;  // 로딩 상태를 표시하기 위한 변수
  File? _processedImage;  // 배경 제거 후의 이미지 파일을 저장하기 위한 변수

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;  // 현재 로그인된 유저 정보를 가져옴
    _loadWardrobe();  // 옷장 아이템을 불러오는 함수 호출
  }

  // Firestore에서 사용자의 옷장 데이터를 불러오는 함수
  Future<void> _loadWardrobe() async {
    if (currentUser == null) return;  // 유저가 로그인되지 않은 경우 함수 종료
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('wardrobe')
        .get();

    // 불러온 데이터를 WardrobeItem 리스트로 변환하여 상태를 업데이트
    setState(() {
      _wardrobeItems = snapshot.docs.map((doc) => WardrobeItem.fromFirestore(doc)).toList();
    });
  }

  // 이미지를 Firestore와 Firebase Storage에 업로드하는 함수
  Future<void> _addCloth(XFile image) async {
    if (currentUser == null) return;  // 유저가 로그인되지 않은 경우 함수 종료

    setState(() {
      _isLoading = true;  // 업로드 중 로딩 상태로 변경
    });

    String fileName = image.name;  // 업로드할 파일의 이름 설정
    File? file = await _removeBackground(image);  // 배경을 제거한 이미지 파일을 생성

    if (file == null) {
      setState(() {
        _isLoading = false;  // 파일이 null인 경우 로딩 상태 해제
      });
      return;  // 파일이 null인 경우 함수 종료
    }

    try {
      // Firebase Storage에 파일 업로드
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref('users/${currentUser!.uid}/wardrobeImages/$fileName')
          .putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();  // 업로드된 파일의 다운로드 URL을 가져옴

      // 새 WardrobeItem 객체 생성
      WardrobeItem newItem = WardrobeItem(
        imageUrl: downloadUrl,
        timestamp: DateTime.now(),
      );

      // Firestore에 새 아이템 추가
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('wardrobe')
          .add(newItem.toFirestore());

      // 상태 업데이트 및 로딩 상태 해제
      setState(() {
        _wardrobeItems.add(newItem);
        _isLoading = false;
      });

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("옷을 등록하였습니다."),
        ),
      );
    } catch (e) {
      // 오류 처리 및 메시지 표시
      print('Error uploading file: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("파일 업로드 중 오류가 발생했습니다."),
        ),
      );
    }
  }

  // 이미지를 서버로 보내서 배경을 제거한 후 로컬에 저장하는 함수
  Future<File?> _removeBackground(XFile image) async {
    Dio dio = Dio();  // Dio 라이브러리를 사용하여 HTTP 요청을 보냄
    try {
      dio.options.contentType = 'multipart/form-data';
      var formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path),
      });

      // 서버로 이미지를 전송하여 배경을 제거한 결과를 받아옴
      final response = await dio.post(
        'http://mango.hanium.kr:5000/bgremove/',
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );

      // 로컬 저장소 경로를 가져와 파일로 저장
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, '${image.name}_result.png');
      final file = File(filePath);
      await file.writeAsBytes(response.data);

      return file;  // 처리된 파일 반환
    } catch (e) {
      print('Error during background removal: $e');
      return null;  // 오류 발생 시 null 반환
    }
  }

  // 사용자가 이미지를 선택했을 때 호출되는 함수
  Future<void> _pickImg(ImageSource source) async {
    if (source == ImageSource.gallery) {
      // 갤러리에서 다중 이미지를 선택한 경우
      final List<XFile>? images = await _imagePicker.pickMultiImage();
      if (images == null) return;

      for (XFile image in images) {
        await _addCloth(image);  // 선택된 각 이미지를 업로드
      }
    } else if (source == ImageSource.camera) {
      // 카메라에서 이미지를 촬영한 경우
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;

      await _addCloth(image);  // 촬영된 이미지를 업로드
    }
  }

  // 옷장 아이템을 삭제하는 함수
  Future<void> _deleteItem(WardrobeItem item) async {
    try {
      // Firestore에서 해당 아이템 삭제
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('wardrobe')
          .where('imageUrl', isEqualTo: item.imageUrl)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });

      // Firebase Storage에서 이미지 파일 삭제
      Uri uri = Uri.parse(item.imageUrl);
      List<String> segments = uri.pathSegments;
      int index = segments.indexOf('o');
      String filePath = segments.sublist(index + 1).join('/');

      await FirebaseStorage.instance.ref(filePath).delete();

      // 상태 업데이트
      setState(() {
        _wardrobeItems.remove(item);
      });

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("옷을 삭제하였습니다."),
        ),
      );
    } catch (e) {
      // 오류 처리 및 메시지 표시
      print('Failed to delete item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("옷 삭제 중 오류가 발생했습니다: $e"),
        ),
      );
    }
  }

  // 옷장 아이템을 그리드로 표시하는 위젯
  Widget _photoPreviewWidget() {
    if (_wardrobeItems.isEmpty) return Container();  // 아이템이 없을 경우 빈 컨테이너 반환

    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,  // 한 줄에 4개의 이미지를 표시
          crossAxisSpacing: 15.0,  // 이미지 사이의 가로 간격
          mainAxisSpacing: 10.0,  // 이미지 사이의 세로 간격
          childAspectRatio: 0.8,  // 이미지의 가로세로 비율 설정
        ),
        itemCount: _wardrobeItems.length,  // 아이템 수에 따라 아이템 개수 설정
        itemBuilder: (context, index) {
          final item = _wardrobeItems[index];
          return GestureDetector(
            onTap: widget.isMultiSelectMode
                ? () {
              // 멀티 선택 모드일 때 아이템 선택/해제 처리
              setState(() {
                if (_selectedImageUrls.contains(item.imageUrl)) {
                  _selectedImageUrls.remove(item.imageUrl);
                } else {
                  _selectedImageUrls.add(item.imageUrl);
                }
              });
            }
                : null,
            child: Stack(
              children: [
                // 아이템 이미지를 표시하는 컨테이너
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(item.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    // 멀티 선택 모드에서 선택된 경우 테두리 색상 변경
                    border: widget.isMultiSelectMode &&
                        _selectedImageUrls.contains(item.imageUrl)
                        ? Border.all(
                      color: Colors.blue,
                      width: 2,
                    )
                        : null,
                  ),
                ),
                // 삭제 버튼
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      await _deleteItem(item);  // 삭제 버튼 클릭 시 아이템 삭제
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 나의 옷장 화면을 구성하는 위젯
  Widget _buildWardrobeScreen() {
    return Column(
      children: [
        SizedBox(height: 10),  // 상단 여백 추가
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _pickImg(ImageSource.camera);  // 카메라에서 이미지 선택
              },
              child: Text("카메라"),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                _pickImg(ImageSource.gallery);  // 갤러리에서 이미지 선택
              },
              child: Text("갤러리"),
            ),
          ],
        ),
        SizedBox(height: 20),  // 버튼과 이미지 목록 사이의 간격 추가
        _isLoading ? CircularProgressIndicator() : _photoPreviewWidget(),  // 로딩 중이면 로딩 인디케이터, 아니면 이미지 그리드 표시
      ],
    );
  }

  // 전체 화면을 구성하는 빌드 함수
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            SafeArea(
              child: Container(
                color: Colors.white,
                child: TabBar(
                  tabs: [
                    Tab(text: "피팅"),  // 피팅 탭
                    Tab(text: "나의 옷장"),  // 나의 옷장 탭
                  ],
                  indicatorColor: Color(0xfff9c63d),  // 탭 선택시 하단의 인디케이터 색상
                  labelColor: Color(0xff121417),  // 선택된 탭의 텍스트 색상
                  unselectedLabelColor: Color(0xff637587),  // 선택되지 않은 탭의 텍스트 색상
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: TabBarView(
                  children: [
                    _buildFitScreen(),  // 피팅 화면
                    _buildWardrobeScreen(),  // 나의 옷장 화면
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: widget.isMultiSelectMode
            ? FloatingActionButton(
          onPressed: () {
            Navigator.pop(context, {'imageUrls': _selectedImageUrls});  // 선택된 이미지 URL들을 반환
          },
          child: Icon(Icons.check),
        )
            : null,
      ),
    );
  }
}

// 해시태그 선택을 위한 StatefulWidget
class HashtagSelector extends StatelessWidget {
  final Map<String, List<String>> categories;
  final Map<String, String> selectedHashtags;
  final Function(String category, String hashtag) onHashtagSelected;

  HashtagSelector({required this.categories, required this.selectedHashtags, required this.onHashtagSelected});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: categories.entries.map((entry) {
        return _buildCategory(entry.key, entry.value);  // 각 카테고리에 대해 해시태그 선택 위젯 생성
      }).toList(),
    );
  }

  // 카테고리별 해시태그 선택 위젯을 구성하는 함수
  Widget _buildCategory(String categoryName, List<String> hashtags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryName,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),  // 카테고리 이름을 굵게 표시
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: hashtags.map((hashtag) {
            final isSelected = selectedHashtags[categoryName] == hashtag;
            return GestureDetector(
              onTap: () {
                onHashtagSelected(categoryName, hashtag);  // 해시태그 선택 시 콜백 호출
              },
              child: Chip(
                label: Text(hashtag),
                backgroundColor: isSelected ? Color(0xfff9c63d) : Colors.white,  // 선택된 경우 배경색 변경
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,  // 텍스트 굵기 조절
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),  // 칩의 모서리 둥글게 설정
                  side: BorderSide(
                    color: isSelected ? Color(0xfff9c63d) : Color(0xFFE1E1E1),  // 테두리 색상 변경
                    width: 0.5,  // 테두리 두께
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),  // 칩 내부 패딩 설정
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
