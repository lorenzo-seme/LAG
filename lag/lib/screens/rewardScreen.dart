import 'package:flutter/material.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:provider/provider.dart';

class RewardScreen extends StatelessWidget {
  RewardScreen({super.key});
  final Map<int, String> fromIntToImg = {
    1: 'reward_1.png',
    2: 'reward_1.png',
    3: 'reward_2.png',
    4: 'reward_3.png',
    5: 'reward_4.png',
    6: 'reward_5.png',
    7: 'reward_6.png',
    8: 'reward_7.png',
    9: 'reward_8.png',
    10: 'reward_9.png',
    11: 'reward_10.png',
    12: 'reward_11.png',
    13: 'reward_12.png',
    14: 'reward_12.png'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: Column(
                children: [
                  const Text("My little plant", style: TextStyle(fontSize: 24, color: Colors.black)),
                  const SizedBox(height: 15,),
                  //Text("${Provider.of<HomeProvider>(context, listen: false).sleepScores["scores"]}", style: TextStyle(fontSize: 24, color: Colors.black)),
                  //Text("Score < 80 --> no crescita pianta\nScore > 80 --> piccola crescita pianta\nScore > 90 --> grande crescita pianta"),
                  //Text("${fromIntToImg[imageToShow(Provider.of<HomeProvider>(context, listen: false).sleepScores["scores"]!)]}"),
                  //Text("${imageToShow(Provider.of<HomeProvider>(context, listen: false).sleepScores["scores"]!)}"),
                  Container(
                      width: 300,
                      height: 400,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            bottomLeft: Radius.circular(15.0),
                            bottomRight: Radius.circular(15.0),
                            topRight: Radius.circular(15.0)),
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage(
                              'assets/rewards/${fromIntToImg[imageToShow(Provider.of<HomeProvider>(context, listen: false).sleepScores["scores"]!)]}'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15,),
                    Text("Your progress taking care of this plant:"),
                    const SizedBox(height: 15,),
                    Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 10),
                      height: 15,
                      child: ClipRRect(
                        borderRadius:const BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          color: Color.fromARGB(255, 255, 115, 115),
                          value: imageToShow(Provider.of<HomeProvider>(context, listen: false).sleepScores["scores"]!) / 14,
                          backgroundColor: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    )
                  
                ],
            ),
          ),
        ),
      ),),
    );
  }

  int imageToShow(List<double> scores){
    int ind = 0;
    for (double value in scores) {
      if (value > 90) {
        ind = ind + 2;
      } else if (value < 80) {
      } 
      else {
        ind++;
      }
    }
    return ind;
  }

}