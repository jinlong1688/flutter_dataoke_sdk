import 'package:dd_taoke_sdk/comment/base_page.dart';
import 'package:dd_taoke_sdk/dd_taoke_sdk.dart';
import 'package:dd_taoke_sdk/model/product.dart';
import 'package:dd_taoke_sdk/params/top_param.dart';
import 'package:flutter/material.dart';

class HotDayPage extends StatefulWidget {
  @override
  _HotDayPageState createState() => _HotDayPageState();
}

class _HotDayPageState extends BasePage<HotDayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('测试'),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categorys
                      .map((e) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${e.cname}'),
                            ),
                          ))
                      .toList(),
                ),
              ),
              ListView.builder(
                itemBuilder: _builder,
                itemCount: products.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _builder(_, index) {
    final item = products[index];
    return Container(
      child: Column(
        children: [
          Image.network(item.mainPic),
          Text('${item.dtitle}'),
        ],
      ),
    );
  }

  @override
  void afterLayout(BuildContext context) {}

  @override
  Future<List<Product>> getProductRequest(int page, int size) {
    return DdTaokeSdk.instance.getTopProducts(
        param: TopParam(rankType: '1', pageId: '$page', pageSize: '$size'));
  }
}
