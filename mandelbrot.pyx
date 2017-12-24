'''
python3 setup.py build_ext --inplace
python3
> import mandelbrot
> mandelbrot.generate_image()

'''
import math
import png

cdef struct Complex:
      double real
      double imaginary

cdef Complex add(Complex c1, Complex c2):
    cdef Complex z
    z.real = c1.real + c2.real
    z.imaginary = c1.imaginary + c2.imaginary
    return z

cdef Complex mult(Complex c1, Complex c2):
    # multiply two complex numbers
    # https://www2.clarku.edu/~djoyce/complex/mult.html
    # (x+yi)(u+vi) = (xu - yv) + (xv + yu)i
    cdef Complex result
    result.real = (c1.real*c2.real - c1.imaginary*c2.imaginary)
    result.imaginary = (c1.real*c2.imaginary + c1.imaginary*c2.real)
    return result

cdef Complex f(Complex c, Complex z):
  # f (c,z) = z^2 + c
  return add(mult(z,z),c)

cdef double magnitude(Complex c):
  return math.sqrt(c.real * c.real + c.imaginary * c.imaginary)

cdef int iter(Complex c, int max_iter):
  cdef Complex z
  z.real = 0
  z.imaginary = 0
  for i in range(max_iter):
    if magnitude(z) > 2.0:
      return i
    z = f(c,z)
  return i

cdef int row[1000]
cdef int size = 1000
def iter_rows():
  cdef:
    double origin = size / 2.0
    double zoom = 0.0000000125
    double pan_horizontal = -1.5
    double pan_vertical = 0.0
    int max_iter = 100
    int i = 0
    Complex c

    int y
    int x
    int length
    int start = 0
    int stop = size
    int step = 1
    int num_iter
  length = len(range(start, stop, step))

  for y in range(length):
      i = 0
      for x in range(length):
        c.real      =   (x - origin) / (origin/zoom) + pan_horizontal
        c.imaginary = - (y - origin) / (origin/zoom) + pan_vertical
        row[i] = iter(c,max_iter)
        i += 1
      yield row

def generate_image():
  # img = png.from_array(iter_rows(), mode="L", info=dict(width=size, height=size, bitdepth=8))
  img = png.from_array(iter_rows(), mode="L", info=dict(width=size, height=size, bitdepth=8))
  img.save("mandelbrot.png")
