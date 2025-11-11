import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calendar_provider.dart';
import '../providers/auth_service.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final initialDate = ref.read(selectedDateProvider);
    DateTime pickedDate = initialDate;
    await showCupertinoModalPopup(context: context, builder: (_) => Container(height: 250, color: CupertinoColors.systemBackground.resolveFrom(context), child: Column(children: [
      Container(color: CupertinoColors.secondarySystemBackground.resolveFrom(context), child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [CupertinoButton(child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)), onPressed: () { ref.read(selectedDateProvider.notifier).state = DateTime(pickedDate.year, pickedDate.month, pickedDate.day); Navigator.of(context).pop(); })])),
      Expanded(child: CupertinoDatePicker(mode: CupertinoDatePickerMode.date, initialDateTime: initialDate, onDateTimeChanged: (d) => pickedDate = d)),
    ])));
  }

  void _showAddEventSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final selectedDate = ref.read(selectedDateProvider);
    DateTime eventDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, DateTime.now().hour);
    showCupertinoModalPopup(context: context, builder: (_) => Container(height: 450, color: CupertinoColors.systemBackground.resolveFrom(context), child: Column(children: [
      CupertinoNavigationBar(leading: CupertinoButton(padding: EdgeInsets.zero, child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()), middle: const Text('Add Manual Event'), trailing: CupertinoButton(padding: EdgeInsets.zero, child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)), onPressed: () { ref.read(manualEventsProvider.notifier).addEvent(titleController.text, eventDateTime); Navigator.of(context).pop(); })),
      Padding(padding: const EdgeInsets.all(16.0), child: CupertinoTextField(controller: titleController, placeholder: 'Event Title', autofocus: true, padding: const EdgeInsets.all(16))),
      Expanded(child: CupertinoDatePicker(mode: CupertinoDatePickerMode.dateAndTime, initialDateTime: eventDateTime, onDateTimeChanged: (d) => eventDateTime = d)),
    ])));
  }

  @override Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsForSelectedDayProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final isSynced = ref.watch(isGoogleConnectedProvider);
    final dateDisplay = selectedDate.month == DateTime.now().month && selectedDate.day == DateTime.now().day ? "Today, ${selectedDate.month}/${selectedDate.day}" : "${selectedDate.month}/${selectedDate.day}";

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: const Text('Event Calendar'), trailing: CupertinoButton(padding: EdgeInsets.zero, child: const Icon(CupertinoIcons.add), onPressed: () => _showAddEventSheet(context, ref))),
      child: SafeArea(bottom: false, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(padding: const EdgeInsets.all(8.0), color: isSynced ? CupertinoColors.systemGreen.withOpacity(0.2) : CupertinoColors.systemRed.withOpacity(0.2), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(isSynced ? CupertinoIcons.cloud_fill : CupertinoIcons.cloud, color: isSynced ? CupertinoColors.systemGreen : CupertinoColors.systemRed, size: 18),
          const SizedBox(width: 8),
          Text(isSynced ? 'Synced with Google Calendar' : 'Google Not Connected', style: TextStyle(color: isSynced ? CupertinoColors.systemGreen : CupertinoColors.systemRed)),
        ])),
        Padding(padding: const EdgeInsets.all(16.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Events on:', style: CupertinoTheme.of(context).textTheme.navTitleTextStyle),
          CupertinoButton(onPressed: () => _selectDate(context, ref), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(CupertinoIcons.calendar, size: 18), const SizedBox(width: 8), Text(dateDisplay)])),
        ])),
        
        // --- THIS IS THE FIX ---
        // Replaced Material 'Divider' with a Cupertino-style Container
        Container(
          height: 1,
          color: CupertinoColors.separator.resolveFrom(context),
        ),
        // --- END OF FIX ---

        Expanded(child: eventsAsync.when(
          data: (events) => events.isEmpty ? Center(child: Text('No events scheduled for $dateDisplay.', style: const TextStyle(color: CupertinoColors.secondaryLabel))) : ListView.builder(itemCount: events.length, itemBuilder: (context, index) {
            final event = events[index];
            final timeDisplay = "${event.date.hour.toString().padLeft(2, '0')}:${event.date.minute.toString().padLeft(2, '0')}";
            return Dismissible(
              key: Key(event.id),
              direction: event.isGoogleEvent ? DismissDirection.none : DismissDirection.endToStart,
              onDismissed: (_) => !event.isGoogleEvent ? ref.read(manualEventsProvider.notifier).removeEvent(event.id) : null,
              background: Container(color: CupertinoColors.systemRed, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(CupertinoIcons.delete_solid, color: CupertinoColors.white)),
              child: CupertinoListTile(
                leading: Icon(event.isGoogleEvent ? CupertinoIcons.cloud_fill : CupertinoIcons.calendar, color: event.isGoogleEvent ? CupertinoColors.systemBlue : CupertinoColors.systemOrange),
                title: Text(event.title),
                subtitle: Text('Time: $timeDisplay'),
                trailing: Text(event.isGoogleEvent ? "SYNCED" : "MANUAL", style: const TextStyle(fontSize: 10, color: CupertinoColors.secondaryLabel)),
              ),
            );
          }),
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: CupertinoColors.systemRed))),
        )),
      ])),
    );
  }
}