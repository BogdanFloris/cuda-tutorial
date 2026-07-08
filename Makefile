NVCC = nvcc
NVCCFLAGS = -O3 -std=c++17 -arch=sm_120
# Hardcode the Fedora host library path so the binary finds the driver natively
LDFLAGS = -Xlinker -rpath=/usr/lib64

TARGET = main
SRC = main.cu

all: $(TARGET)

$(TARGET): $(SRC)
	$(NVCC) $(NVCCFLAGS) $(LDFLAGS) -o $@ $<

profile: $(TARGET)
	LD_LIBRARY_PATH=/usr/lib64:$$LD_LIBRARY_PATH ncu ./$(TARGET)

clean:
	rm -f $(TARGET)

.PHONY: all clean
