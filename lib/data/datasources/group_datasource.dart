import '../../core/config/supabase_config.dart';
import '../models/group_model.dart';

/// Supabase data source for group operations
class GroupDataSource {
  final _client = SupabaseConfig.client;

  /// Get all groups for current user
  Future<List<GroupModel>> getUserGroups() async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('group_members')
        .select('group_id, groups(*)')
        .eq('user_id', userId);

    return (response as List)
        .map((item) => GroupModel.fromJson(item['groups'] as Map<String, dynamic>))
        .toList();
  }

  /// Create a new group
  Future<GroupModel> createGroup({
    required String name,
    String? description,
    String? currency,
  }) async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Create group
    final groupResponse = await _client
        .from('groups')
        .insert({
          'name': name,
          'description': description,
          'created_by': userId,
          'currency': currency ?? 'PKR',
        })
        .select()
        .single();

    final group = GroupModel.fromJson(groupResponse);

    // Add creator as admin member
    await _client.from('group_members').insert({
      'group_id': group.groupId,
      'user_id': userId,
      'role': 'admin',
    });

    return group;
  }

  /// Get group members
  Future<List<GroupMemberModel>> getGroupMembers(String groupId) async {
    final response = await _client
        .from('group_members')
        .select()
        .eq('group_id', groupId);

    return (response as List)
        .map((json) => GroupMemberModel.fromJson(json))
        .toList();
  }

  /// Add member to group
  Future<void> addMember({
    required String groupId,
    required String userEmail,
  }) async {
    // Find user by email
    final userResponse = await _client
        .from('users')
        .select('user_id')
        .eq('email', userEmail)
        .single();

    final userId = userResponse['user_id'] as String;

    // Add as member
    await _client.from('group_members').insert({
      'group_id': groupId,
      'user_id': userId,
      'role': 'member',
    });
  }

  /// Delete group (admin only)
  Future<void> deleteGroup(String groupId) async {
    final currentUserId = SupabaseConfig.currentUser?.id;
    if (currentUserId == null) throw Exception('User not authenticated');

    // Verify current user is admin of this group
    final currentUserMembership = await _client
        .from('group_members')
        .select('role')
        .eq('group_id', groupId)
        .eq('user_id', currentUserId)
        .single();

    if (currentUserMembership['role'] != 'admin') {
      throw Exception('Only admins can delete groups');
    }

    // Delete group (cascade will handle members, expenses, splits, and settlements)
    await _client.from('groups').delete().eq('group_id', groupId);
  }

  /// Remove member from group (admin only)
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    final currentUserId = SupabaseConfig.currentUser?.id;
    if (currentUserId == null) throw Exception('User not authenticated');

    // Check if current user is admin
    final currentUserMembership = await _client
        .from('group_members')
        .select('role')
        .eq('group_id', groupId)
        .eq('user_id', currentUserId)
        .single();

    if (currentUserMembership['role'] != 'admin') {
      throw Exception('Only admins can remove members');
    }

    // Don't allow removing yourself if you're the only admin
    if (userId == currentUserId) {
      final adminCount = await _client
          .from('group_members')
          .select()
          .eq('group_id', groupId)
          .eq('role', 'admin');

      if ((adminCount as List).length <= 1) {
        throw Exception('Cannot remove the last admin');
      }
    }

    // Remove member
    await _client
        .from('group_members')
        .delete()
        .eq('group_id', groupId)
        .eq('user_id', userId);
  }
}
