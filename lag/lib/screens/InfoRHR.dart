import 'package:flutter/material.dart';

class InfoRHR extends StatelessWidget {
  const InfoRHR({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Why RHR reflects my health status?'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Hero(
                tag: 'rhr',
                child:  Container(
                  width: 300,
                  height: 200,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        bottomLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0),
                        topRight: Radius.circular(15.0)),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(
                          'assets/rhr.png'),
                    ),
                  ),
                ),),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam sed velit neque. Quisque facilisis gravida tincidunt. In volutpat mollis metus, ut viverra massa rhoncus vel. Aenean vestibulum dignissim ultricies. Duis quis luctus elit, ac commodo orci. Curabitur feugiat, ante ac auctor malesuada, arcu leo tempus quam, eu tincidunt nisi lorem quis nisi. Proin pulvinar dolor eu diam sollicitudin, id viverra libero porttitor. Nullam venenatis tortor vitae rhoncus luctus. Sed nec enim finibus, varius felis id, facilisis diam. Vestibulum fermentum urna sit amet augue eleifend consectetur. Nam tincidunt hendrerit ex, nec dignissim dui vulputate tempor. Duis auctor pulvinar nunc ut pharetra.'),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
