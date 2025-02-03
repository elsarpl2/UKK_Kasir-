import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrasiPage extends StatefulWidget {
  const RegistrasiPage({Key? key}) : super(key: key);

  @override
  _RegistrasiPageState createState() => _RegistrasiPageState();
}

class _RegistrasiPageState extends State<RegistrasiPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> userList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await supabase.from('user').select().order('id');
      if (response is List) {
        setState(() {
          userList = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Gagal memuat data pengguna.');
    }
  }

  Future<void> addUser(String username, String password, String role) async {
    try {
      await supabase.from('user').insert({
        'username': username,
        'password': password,
        'role': role,
      }).select();
      fetchUsers();
      _showSuccess('User berhasil ditambahkan');
    } catch (e) {
      _showError('Gagal menambahkan user.');
    }
  }

  Future<void> editUser(int id, String username, String password, String role) async {
  try {
    await supabase.from('user').update({
      'username': username,
      'password': password,
      'role': role,
    }).eq('id', id).select();
    fetchUsers();
    _showSuccess('User berhasil diperbarui');
  } catch (e) {
    _showError('Gagal mengedit user.');
  }
}


  Future<void> deleteUser(int id) async {
    try {
      await supabase.from('user').delete().eq('id', id).select();
      fetchUsers();
      _showSuccess('User berhasil dihapus');
    } catch (e) {
      _showError('Gagal menghapus user.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showFormDialog({int? id, String? username, String? password, String? role}) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController usernameController = TextEditingController(text: username ?? '');
    final TextEditingController passwordController = TextEditingController(text: password ?? '');
    String? selectedRole = role;
    bool obscureText = true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? 'Tambah User' : 'Edit User'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => value!.isEmpty ? 'Username tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: passwordController,
                obscureText: obscureText,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Password tidak boleh kosong' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'Petugas', child: Text('Petugas')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
                validator: (value) => value == null ? 'Role tidak boleh kosong' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (id == null) {
                  addUser(usernameController.text, passwordController.text, selectedRole!);
                } else {
                  editUser(id, usernameController.text, passwordController.text, selectedRole!);
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data User')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userList.isEmpty
              ? const Center(child: Text('Tidak ada data user.'))
              : ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, index) {
                    final user = userList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(user['username'] ?? 'Unknown'),
                        subtitle: Text('Role: ${user['role'] ?? 'Unknown'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showFormDialog(
                                  id: user['id'],
                                  username: user['username'],
                                  password: user['password'],
                                  role: user['role'],
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteUser(user['id']);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
