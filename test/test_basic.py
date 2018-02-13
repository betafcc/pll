from p import P


def test_doesnt_break():
    _ = P\
        .from_non_coroutines(range(10))\
        .map(lambda x: x ** 2)\
        .as_completed()\
        .aggregate(set)

    assert _ == set(x ** 2 for x in range(10))
