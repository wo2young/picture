import 'package:flutter/material.dart';
import 'package:family_app/services/family_service.dart';

class FamilyFirstCreatePage extends StatefulWidget {
  const FamilyFirstCreatePage({super.key});

  @override
  State<FamilyFirstCreatePage> createState() => _FamilyFirstCreatePageState();
}

class _FamilyFirstCreatePageState extends State<FamilyFirstCreatePage> {
  final _nameController = TextEditingController();
  String _familyType = 'nuclear';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ============================
  // 가족 생성 (API 연결은 나중)
  // ============================
  Future<void> _createFamily() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _error = '가족 이름을 입력해주세요.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await FamilyService.createFamily(
        name: name,
        type: _familyType,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true); // ✅ 생성 성공
    } catch (e) {
      setState(() {
        _error = '가족 생성에 실패했습니다.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async => false, // 🔒 뒤로가기 차단
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('가족 만들기'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              Text(
                '가족을 먼저 만들어주세요',
                style: theme.textTheme.titleLarge,
              ),

              const SizedBox(height: 8),

              Text(
                '사진과 일기는 가족 단위로 관리돼요.',
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 32),

              // ======================
              // 가족 이름
              // ======================
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '가족 이름',
                  hintText: '예: 우리 가족, 김씨네',
                  errorText: _error,
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // ======================
              // 가족 유형
              // ======================
              Text(
                '가족 유형',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              _familyTypeTile(
                value: 'nuclear',
                title: '우리 가족',
                subtitle: '부모·자녀 중심',
              ),
              _familyTypeTile(
                value: 'maternal',
                title: '외가',
                subtitle: '어머니 쪽 가족',
              ),
              _familyTypeTile(
                value: 'paternal',
                title: '친가',
                subtitle: '아버지 쪽 가족',
              ),

              const Spacer(),

              // ======================
              // 생성 버튼
              // ======================
              ElevatedButton(
                onPressed: _loading ? null : _createFamily,
                child: _loading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('가족 만들기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================
  // 가족 타입 선택 타일
  // ============================
  Widget _familyTypeTile({
    required String value,
    required String title,
    required String subtitle,
  }) {
    return RadioListTile<String>(
      value: value,
      groupValue: _familyType,
      onChanged: (v) {
        setState(() {
          _familyType = v!;
        });
      },
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
