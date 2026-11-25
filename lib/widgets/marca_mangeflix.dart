import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MarcaMangeflix extends StatelessWidget {
  const MarcaMangeflix({super.key, this.tamanho = 42});

  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: tamanho,
          height: tamanho,
          decoration: BoxDecoration(
            gradient: AppColors.gradiente,
            borderRadius: BorderRadius.circular(tamanho * 0.28),
          ),
          child: Icon(
            Icons.movie_outlined,
            color: Colors.white,
            size: tamanho * 0.6,
          ),
        ),
        SizedBox(width: tamanho * 0.25),
        Text(
          'MangeFlix',
          style: TextStyle(
            color: AppColors.titulo,
            fontSize: tamanho * 0.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
