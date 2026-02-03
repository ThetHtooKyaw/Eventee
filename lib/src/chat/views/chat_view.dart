import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/src/chat/view_models/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().getCurrentUser();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Chat AI Assistant'),
        backgroundColor: AppColor.background,
      ),
      body: Consumer<ChatViewModel>(
        builder: (context, vm, _) {
          if (vm.chatError != null) {
            if (vm.chatError != null) {
              return Center(child: Text('Error: ${vm.chatError!.message}'));
            }
          }

          if (vm.currentUserId == null) {
            return const LoadingColumn(message: 'Initializing...');
          }

          return Column(
            children: [
              // Chat Messages List
              Expanded(
                child: GroupedListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppFormat.secondaryPadding,
                  ),
                  reverse: true,
                  order: GroupedListOrder.DESC,
                  useStickyGroupSeparators: true,
                  floatingHeader: true,
                  elements: vm.messages,
                  groupBy: (message) => DateTime(
                    message.date.year,
                    message.date.month,
                    message.date.day,
                  ),
                  groupHeaderBuilder: (message) => SizedBox(
                    height: 40,
                    child: Center(
                      child: Text(DateFormat.yMMMd().format(message.date)),
                    ),
                  ),
                  itemBuilder: (context, message) => Align(
                    alignment: message.isSentByMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,

                    child: Row(
                      mainAxisAlignment: message.isSentByMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        // AI Avater (Left side)
                        if (!message.isSentByMe) ...[
                          CircleAvatar(
                            backgroundColor: AppColor.white,
                            child: const Icon(
                              Icons.smart_toy,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],

                        // Message Bubble
                        Flexible(
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppFormat.secondaryPadding,
                              ),
                              child: Text(message.text),
                            ),
                          ),
                        ),

                        // User Avatar (Right side)
                        if (message.isSentByMe) ...[
                          const SizedBox(width: 10),
                          const CircleAvatar(
                            backgroundColor: AppColor.white,
                            child: Icon(Icons.person),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // TextField and Send Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppFormat.secondaryPadding,
                  vertical: AppFormat.primaryPadding,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Type your message here...',
                        ),
                        onSubmitted: (text) {
                          vm.sendMessage(text: text.trim());
                          _textController.clear();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        vm.sendMessage(text: _textController.text.trim());
                        _textController.clear();
                      },
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
