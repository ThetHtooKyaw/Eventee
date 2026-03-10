import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/src/chat/models/message.dart';
import 'package:eventee/src/chat/view_models/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().getCurrentUser();
    });
  }

  Future<void> _handleSendMessage() async {
    final vm = context.read<ChatViewModel>();

    vm.sendMessage();

    if (vm.errorMessage != null) {
      AppSnackbars.showErrorSnackbar(context, vm.errorMessage!);
      vm.setError(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isScreenLoading = context.select<ChatViewModel, bool>(
      (vm) => vm.isScreenLoading,
    );

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: AppColor.white,
            leadingWidth: 70,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 32),
            ),
            title: Text('Eventee Assistant', style: t.textTheme.titleSmall),
          ),

          // TextField and Send Button
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppFormat.secondaryPadding,
              vertical: AppFormat.primaryPadding,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: context.read<ChatViewModel>().textController,
                    decoration: const InputDecoration(
                      hintText: 'Ask Eventee...',
                    ),
                    onSubmitted: (_) => _handleSendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _handleSendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppFormat.secondaryBorderRadius,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),

          body: Selector<ChatViewModel, List<Message>>(
            selector: (_, vm) => vm.messages,
            shouldRebuild: (prevuous, next) => true,
            builder: (context, messages, child) {
              return GroupedListView(
                padding: const EdgeInsets.all(AppFormat.secondaryPadding),
                reverse: true,
                order: GroupedListOrder.DESC,
                useStickyGroupSeparators: false,
                floatingHeader: false,
                elements: messages,
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
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppFormat.primaryPadding,
                              vertical: AppFormat.secondaryPadding,
                            ),
                            child: MarkdownBody(
                              data: message.text,
                              styleSheet: MarkdownStyleSheet(
                                p: t.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.normal,
                                ),
                                strong: t.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // User Avatar (Right side)
                      // if (message.isSentByMe) ...[
                      //   const SizedBox(width: 10),
                      //   const CircleAvatar(
                      //     backgroundColor: AppColor.white,
                      //     child: Icon(Icons.person),
                      //   ),
                      // ],
                    ],
                  ),
                ),
                separator: const SizedBox(height: 10),
              );
            },
          ),
        ),

        if (isScreenLoading)
          LoadingOverlayColumn(message: 'Initializing chat assistant'),
      ],
    );
  }
}
