package main

import "testing"

func TestHello(t *testing.T) {
	type args struct {
		v string
	}
	tests := []struct {
		name    string
		args    args
		want    string
		wantErr bool
	}{
		{
			name: "When v = 'world', then return 'world'.",
			args: args{
				v: "world",
			},
			want: "world",
		},
		{
			name: "When v = 'hello', then return error.",
			args: args{
				v: "hello",
			},
			wantErr: true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := Hello(tt.args.v)
			if (err != nil) != tt.wantErr {
				t.Errorf("Hello() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if got != tt.want {
				t.Errorf("Hello() = %v, want %v", got, tt.want)
			}
		})
	}
}
