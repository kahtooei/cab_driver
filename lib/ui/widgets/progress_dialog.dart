import 'package:cab_driver/shared/utils/colors.dart';
import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  const ProgressDialog(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: 70,
        padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: MyColors.colorBlue,
            ),
            Expanded(
                child: Center(
              child: Text(
                status,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
