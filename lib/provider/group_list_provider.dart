import 'package:flutter/cupertino.dart';
import 'package:jmessage_flutter/jmessage_flutter.dart';

import 'jmessage_manager_provider.dart';

class GroupListProvider with ChangeNotifier {
  List<JMConversationInfo> _groupList = [];

  List<JMConversationInfo> get groupList => _groupList;

  List<String> _groupIdArray = [];
  List<String> get groupIdArray => _groupIdArray;

  int _unreadCount = 0;

  int get unreadCount => _unreadCount;
  

  set unreadCount(value){
    _unreadCount = value;
    notifyListeners();
  }


  set groupIdArray(value){
    _groupIdArray = value;
    getConversationList();
  }

  loginStatusCheck() async {
    // var userModel = UserInfoModel.fromJson(SpUtil.getObject("UserInfo"));
    jmessage
        .login(username: "flyingfish", password: "123456")
        .then((userInfo) {
      print(userInfo);
      receiveMessageListener();
      receiveApplyJoinGroupApprovalListener();
      getMyGroup();
    }).catchError((error) {
      // PPToast.show('用户群聊登录失败！');
      print(error);
    });
  }

  receiveMessageListener() async {
    jmessage.addReceiveMessageListener((msg) {
      if (msg is JMEventMessage) {
        getMyGroup();
      }else{
        getConversationList();
      }
    });
  }
  /// 监听入群申请
  receiveApplyJoinGroupApprovalListener() async {
    jmessage.addReceiveApplyJoinGroupApprovalListener((event){
      jmessage.processApplyJoinGroup(events: [event.eventId],isAgree: true,reason: '同意', isRespondInviter: false).then((result){

      }).catchError((error){
        
      });
    });
  }

  getMyGroup() {
    jmessage.getGroupIds().then((groupIds) {
      groupIdArray = groupIds;
    }).catchError((error) {});
  }

  getConversationList() async {
    print("************************");

    jmessage.getConversations().then((allConversations) {
      print("************************");
      print(allConversations);

      _groupList = allConversations;
      if (_groupList == null) {
        _groupList = [];
      } else {
        int unreadNum = 0;
        _groupList.removeWhere((conversation) {
          if (conversation.conversationType == JMConversationType.group) {
            var groupInfo = JMGroupInfo.fromJson(conversation.target.toJson());
            if (_groupIdArray.contains(groupInfo.id)) {
              unreadNum += conversation.unreadCount;
              return false;
            } else {
              jmessage.deleteConversation(
                  target: JMGroup.fromJson(
                      {'type': JMGroupType.private, 'groupId': groupInfo.id}));
              return true;
            }
          } else {
            return true;
          }
        });
        unreadCount = unreadNum;
        notifyListeners();
      }
    }).catchError((error) {
      print(error);
      loginStatusCheck();
    });
    notifyListeners();

  }

  @override
  void dispose() {
    super.dispose();
    // jmessage.removeReceiveMessageListener((message){});
  }
}
