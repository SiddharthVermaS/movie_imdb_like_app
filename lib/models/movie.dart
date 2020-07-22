class Movie {
  int id,vote_count;
  String title,poster_path,release_date;

  Movie.fromJsonHome(Map<String, dynamic> map)  {
    id=map['id'];
    vote_count=map['vote_count'];
    title=map['title'];
    poster_path=map['poster_path']==null?map['backdrop_path']==null?'':map['backdrop_path'].substring(0):map['poster_path'].substring(0);
    release_date=map['release_date'];
  }














}