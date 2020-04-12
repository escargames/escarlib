
#include <lol/engine.h>

int main(int, char **argv)
{
    lol::image img;
    img.load(argv[1]);

    auto size = img.size();
    lol::array2d<lol::vec4> &data = img.lock2d<lol::PixelFormat::RGBA_F32>();

    std::vector<int> accum;

    for (int i = 0; i < size.x; ++i)
    {
        int val = 0;
        for (int j = 0; j < size.y; ++j)
            if (lol::dot(data[i][j].rgb, lol::vec3(1.)) < 0.01)
                val += 1 << j;
        accum.push_back(val);

        if (i + 1 == size.x || (data[i + 1][0].r > 0.8 && data[i + 1][0].g < 0.2))
        {
             printf("  [\"?\"]={");
             for (auto n : accum)
                 printf("%d,", n);
             printf("},\n");
             accum.clear();
             ++i;
        }
    }

    img.unlock2d(data);
}

