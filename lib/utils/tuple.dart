class Tuple2<A, B> {
  late A v1;
  late B v2;

  Tuple2(this.v1, this.v2);

  @override
  String toString() {
    return "($v1, $v2)";
  }
}

class Tuple3<A, B, C> {
  late A v1;
  late B v2;
  late C v3;

  Tuple3(this.v1, this.v2, this.v3);

  @override
  String toString() {
    return "($v1, $v2, $v3)";
  }
}

class Tuple4<A, B, C, D> {
  late A v1;
  late B v2;
  late C v3;
  late D v4;

  Tuple4(this.v1, this.v2, this.v3, this.v4);

  @override
  String toString() {
    return "($v1, $v2, $v3, $v4)";
  }
}
