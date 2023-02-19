abstract class RequestStatus<T> {
  final T? response;
  final String? error;
  RequestStatus(this.response, this.error);
}

class SuccessRequest<T> extends RequestStatus<T> {
  SuccessRequest(T? response) : super(response, null);
}

class FailedRequest<T> extends RequestStatus<T> {
  FailedRequest(String error) : super(null, error);
}
