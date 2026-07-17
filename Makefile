NVCC = nvcc
NVCCFLAGS = -O3 -std=c++17 -arch=sm_120
# Hardcode the NixOS driver path so the binary finds libcuda.so natively
LDFLAGS = -Xlinker -rpath=/run/opengl-driver/lib

TARGET = main
SRC = main.cu

all: $(TARGET)

$(TARGET): $(SRC)
	$(NVCC) $(NVCCFLAGS) $(LDFLAGS) -o $@ $<

clean:
	rm -f $(TARGET)

.PHONY: all clean
