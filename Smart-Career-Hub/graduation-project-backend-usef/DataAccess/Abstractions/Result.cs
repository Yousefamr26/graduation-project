using System;

namespace DataAccess.Abstractions
{
    public class Result
    {
        public bool IsSuccess { get; }
        public bool IsFailure => !IsSuccess;
        public Error Error { get; }

        protected Result(bool isSuccess, Error error)
        {
            if ((isSuccess && error != Error.None) || (!isSuccess && error == Error.None))
                throw new InvalidOperationException("Invalid combination of success/failure and error.");

            IsSuccess = isSuccess;
            Error = error;
        }

        public static Result Success() => new Result(true, Error.None);
        public static Result Failure(Error error) => new Result(false, error);

        public static Result<TValue> Success<TValue>(TValue value) => new Result<TValue>(value, true, Error.None);
        public static Result<TValue> Failure<TValue>(Error error) => new Result<TValue>(default, false, error);
    }

    public class Result<TValue> : Result
    {
        private readonly TValue? _value;

        public Result(TValue? value, bool isSuccess, Error error) : base(isSuccess, error)
        {
            _value = value;
        }

        public TValue Value
        {
            get
            {
                if (!IsSuccess)
                    throw new InvalidOperationException("Cannot access Value when the result is a failure.");
                return _value!;
            }
        }
    }
}
