import 'package:flutter/material.dart';
import '../models/tvshow.dart';
import 'package:movie_geek/key_data.dart' as kd;
import 'package:auto_size_text/auto_size_text.dart';

class SeasonSection extends StatefulWidget {
  List<Season> seasonList;

  SeasonSection({
    this.seasonList,
  });

  @override
  _SeasonSectionState createState() => _SeasonSectionState();
}

class _SeasonSectionState extends State<SeasonSection> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = false;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.seasonList.length,
      itemBuilder: (context, index) => ExpansionTile(
        key: PageStorageKey<String>(this.widget.seasonList[index].name),
        title: Container(
          child: Text(this.widget.seasonList[index].name),
        ),
        trailing: (_isExpanded == true)
            ? Icon(Icons.keyboard_arrow_down_sharp)
            : Icon(Icons.keyboard_arrow_up_sharp),
        onExpansionChanged: (value) {
          setState(() {
            _isExpanded = value;
          });
        },
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: (this.widget.seasonList[index].posterPath == null)
                    ? Image.network(
                        kd.noPosterPath,
                        height: 200,
                        width: 150,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        kd.imgUrl + this.widget.seasonList[index].posterPath,
                        height: 200,
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(50),
                child: Text(
                  this.widget.seasonList[index].episodesCount.toString() +
                      ' episodes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: AutoSizeText(
              this.widget.seasonList[index].overview,
            ),
          ),
        ],
      ),
    );
  }
}
