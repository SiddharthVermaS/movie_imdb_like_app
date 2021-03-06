import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:movie_imdb_like_app/blocs/details/bloc.dart';
import 'package:movie_imdb_like_app/blocs/home/bloc.dart';
import 'package:movie_imdb_like_app/models/movie.dart';
import 'package:movie_imdb_like_app/networks/constant_base_urls.dart';
import 'package:movie_imdb_like_app/screens/details.dart';
import 'package:movie_imdb_like_app/utils/global.dart';
import 'package:shimmer/shimmer.dart';

class Home extends StatefulWidget {
  _HomeState createState()=>_HomeState();
}

class _HomeState extends State<Home>  {
   HomeBloc homeBloc;
  
  void initState()  {
    super.initState();
    Future.delayed(Duration.zero,() {
    Global.width=MediaQuery.of(context).size.width;
    Global.height=MediaQuery.of(context).size.height;
    });
    homeBloc=BlocProvider.of<HomeBloc>(context);
    homeBloc.appWidgets.context=context;

    homeBloc.add(FetchMoviesEvent());
  }


  void dispose()  {
    super.dispose();
    homeBloc.dispose();
    homeBloc.close();
  }


  Widget build(BuildContext context)  {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: StreamBuilder(
          initialData: false,
        stream: homeBloc.showSearchBarStream,
        builder: (BuildContext context, AsyncSnapshot<bool> asyncSnapshot)  {
        return AppBar(
         backgroundColor: Colors.black87,
        centerTitle:  asyncSnapshot.data,
        title: asyncSnapshot.data?TextField(
          onChanged: (String value) {
            homeBloc.queryStreamSink.add(value);
          },
          style: TextStyle(color: Colors.white),
          autofocus: true,
          cursorColor: Colors.white70,
          controller: homeBloc.queryTextEditingController,
         textInputAction: TextInputAction.search,
         onSubmitted: (String value)  {
            homeBloc.searchMovie();
         },
          decoration: InputDecoration(
            
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
           prefixIcon: IconButton(icon: Icon(Icons.search, color: Colors.white), onPressed: () {
            
            homeBloc.searchMovie();
           },) ,
          suffixIcon:  IconButton(icon: Icon(Icons.close, color: Colors.white), onPressed: () {
            homeBloc.showSearchBarStreamSink.add(false);
            homeBloc.queryTextEditingController.text='';
            homeBloc.queryStreamSink.add('');
             homeBloc.add(ClearSearchMoviesEvent());
             
           },) 
           
          ),
        ):Text('IMDB Movies', style: TextStyle(color: Colors.white,)),
        actions: <Widget>[
          asyncSnapshot.data?SizedBox(width: 0,height: 0):
          IconButton(icon: Icon(Icons.search, color: Colors.white), onPressed:(){
            homeBloc.showSearchBarStreamSink.add(true);
          })
        ],
      );
      })),
    body:  Container(
       color: Colors.black87,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: BlocListener<HomeBloc, HomeState>  (
          listener: (BuildContext context, HomeState state) {
            if(state is HomeErrorState)  {
              homeBloc.appWidgets.showToast(state.message);
            }
          },
          child: BlocBuilder<HomeBloc, HomeState> (
            builder: (context, state)  {
            if(state is HomeInitialState) {
              return loadShimmer();
            }
            else if(state is HomeLoadedState) {
               return loadMovies(state.moviesList);
            }else if(state is HomeSearchLoadedState) {
               return loadMovies(state.moviesList);
            }else if(state is HomeErrorState)  {
               return loadMovies(state.moviesList);
            }
            return homeBloc.appWidgets.getCircularProgressIndicator();
          },)
        )
      )
 );
  }

  Widget loadMovies(List<Movie> moviesList) {
    return LazyLoadScrollView(
      onEndOfPage: ()=>homeBloc.add(FetchMoviesEvent()),
      scrollOffset: 80,
      child: ListView.builder(
        controller: homeBloc.scrollController,
      itemCount: moviesList.length,
      itemBuilder: (BuildContext context, int index) {
        return  Container(
          color: Colors.grey[900],
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            Container(
              width:Global.width,
              height: Global.height-(Global.height*0.55),
             child: FadeInImage.assetNetwork(
        placeholder: 'assets/images/loading.gif',
        image: '${ConstantBaseUrls.baseImageUrl}${moviesList[index].poster_path}',
        fit: BoxFit.cover,
        height: 250.0,
      )),
           
             Container(
             margin: EdgeInsets.fromLTRB(15, 7, 15, 7),
             child: Row(children: <Widget>[
               Expanded(child:Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children:<Widget>  [
                 Text('${moviesList[index].title}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300 , fontSize: 16)),
                 SizedBox(height: 5),
                   Text('${homeBloc.convertDate.convertToMMMMMddyyyy(moviesList[index].release_date)}', style: TextStyle(color: Colors.white, fontSize: 12)),
            
            ])),
            IconButton(icon: Icon(Icons.visibility, color: Colors.white), onPressed: ()  {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>BlocProvider(create:(context)=> DetailsBloc(), child: Details(movie: moviesList[index]))));
            })
            ]))
          ]));
      },
    ));

  } 
    Widget loadShimmer()  {
    return Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100],
                enabled: false,
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                      child: ListView(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        
                        Container(margin: EdgeInsets.fromLTRB(0, 5, 0, 5), height: 195, width: double.infinity,color: Colors.white),
                        Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          height: 50, width: double.infinity,
                          child: Row(mainAxisAlignment: MainAxisAlignment.start,children: <Widget>[
                           
                            Container(margin: EdgeInsets.only(left: 10),width: 180, height: 20,color: Colors.white),
                          ],)
                        ),
                      
                    ],)
                  )
                  
                ),
              );
  }
}