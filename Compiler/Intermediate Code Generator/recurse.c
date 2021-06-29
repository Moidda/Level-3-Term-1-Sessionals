int recurse(int x) {
    if(x == 0) return 0;
    return x + recurse(x-1);
}

int main() {
    int a;
    a = recurse(5);
    println(a);
    return 0;
} 