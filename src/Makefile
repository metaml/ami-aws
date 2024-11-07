image:;	docker build --platform linux/amd64 --tag ami-lambda:latest .

test: export MODE = dev
test:; python ./analytics.py

clean:;	rm -f *~
