library;


mixin class CancellationToken {
  bool _cancelled = false;

  bool get cancelled => _cancelled;

  void cancel() => _cancelled = true;
}

mixin class CompletionToken {
  bool _completed = false;

  bool get completed => _completed;

  void complete() => _completed = true;
}

class Token with CancellationToken, CompletionToken {
  @override
  bool get cancelled => _cancelled && !completed;
}
