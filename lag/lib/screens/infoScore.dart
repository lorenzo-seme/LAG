import 'package:flutter/material.dart';

class InfoScore extends StatelessWidget {
  const InfoScore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: [
                const Text("How do we calculate your score?", style: TextStyle(fontSize: 24, color: Colors.black)),
                SizedBox(height: 15),
                Hero(
                  tag: 'score',
                  child: Container(
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
                            'assets/sleep.jpg'),
                      ),
                    ),
                  ),),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam sed velit neque. Quisque facilisis gravida tincidunt. In volutpat mollis metus, ut viverra massa rhoncus vel. Aenean vestibulum dignissim ultricies. Duis quis luctus elit, ac commodo orci. Curabitur feugiat, ante ac auctor malesuada, arcu leo tempus quam, eu tincidunt nisi lorem quis nisi. Proin pulvinar dolor eu diam sollicitudin, id viverra libero porttitor. Nullam venenatis tortor vitae rhoncus luctus. Sed nec enim finibus, varius felis id, facilisis diam. Vestibulum fermentum urna sit amet augue eleifend consectetur. Nam tincidunt hendrerit ex, nec dignissim dui vulputate tempor. Duis auctor pulvinar nunc ut pharetra.'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
