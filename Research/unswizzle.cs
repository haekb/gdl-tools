private void readTexPSMT4(int dbp, int dbw, int dsax, int dsay, int rrw, int rrh, ref byte[] data)
{
    dbw = dbw >> 1;
    int index = 0;
    int num2 = dbp * 0x40;
    bool flag = false;
    for (int i = dsay; i < (dsay + rrh); i++)
    {
        for (int j = dsax; j < (dsax + rrw); j++)
        {
            int num5 = j / 0x80;
            int num6 = i / 0x80;
            int num7 = num5 + (num6 * dbw);
            int num8 = j - (num5 * 0x80);
            int num9 = i - (num6 * 0x80);
            int num10 = num8 / 0x20;
            int num11 = num9 / 0x10;
            int num12 = this.block4[num10 + (num11 * 4)];
            int num13 = num8 - (num10 * 0x20);
            int num14 = num9 - (num11 * 0x10);
            int num15 = num14 / 4;
            int num16 = num13;
            int num17 = num14 - (num15 * 4);
            int num18 = this.columnWord4[num15 & 1, num16 + (num17 * 0x20)];
            int num19 = this.columnByte4[num16 + (num17 * 0x20)];
            int num20 = ((((num2 + (num7 * 0x800)) + (num12 * 0x40)) + (num15 * 0x10)) + num18) * 4;
            byte num21 = data[index];
            byte num22 = this.gsmem[num20 + (num19 >> 1)];
            if ((num19 & 1) != 0)
            {
                if (flag)
                {
                    data[index] = (byte) ((num21 & 15) | (num22 & 240));
                }
                else
                {
                    data[index] = (byte) ((num21 & 240) | ((num22 >> 4) & 15));
                }
            }
            else if (flag)
            {
                data[index] = (byte) ((num21 & 15) | ((num22 << 4) & 240));
            }
            else
            {
                data[index] = (byte) ((num21 & 240) | (num22 & 15));
            }
            if (flag)
            {
                index++;
            }
            flag = !flag;
        }
    }
}

private void readTexPSMT8(int dbp, int dbw, int dsax, int dsay, int rrw, int rrh, ref byte[] data)
{
    dbw = dbw >> 1;
    int index = 0;
    int num2 = dbp * 0x40;
    for (int i = dsay; i < (dsay + rrh); i++)
    {
        for (int j = dsax; j < (dsax + rrw); j++)
        {
            int num5 = j / 0x80;
            int num6 = i / 0x40;
            int num7 = num5 + (num6 * dbw);
            int num8 = j - (num5 * 0x80);
            int num9 = i - (num6 * 0x40);
            int num10 = num8 / 0x10;
            int num11 = num9 / 0x10;
            int num12 = this.block8[num10 + (num11 * 8)];
            int num13 = num8 - (num10 * 0x10);
            int num14 = num9 - (num11 * 0x10);
            int num15 = num14 / 4;
            int num16 = num13;
            int num17 = num14 - (num15 * 4);
            int num18 = this.columnWord8[num15 & 1, num16 + (num17 * 0x10)];
            int num19 = this.columnByte8[num16 + (num17 * 0x10)];
            int num20 = ((((num2 + (num7 * 0x800)) + (num12 * 0x40)) + (num15 * 0x10)) + num18) * 4;
            data[index] = this.gsmem[num20 + num19];
            index++;
        }
    }
}

 
private void writeTexPSMCT32(int dbp, int dbw, int dsax, int dsay, int rrw, int rrh, byte[] data)
{
    int index = 0;
    int num2 = dbp * 0x40;
    for (int i = dsay; i < (dsay + rrh); i++)
    {
        for (int j = dsax; j < (dsax + rrw); j++)
        {
            int num5 = j / 0x40;
            int num6 = i / 0x20;
            int num7 = num5 + (num6 * dbw);
            int num8 = j - (num5 * 0x40);
            int num9 = i - (num6 * 0x20);
            int num10 = num8 / 8;
            int num11 = num9 / 8;
            int num12 = this.block32[num10 + (num11 * 8)];
            int num13 = num8 - (num10 * 8);
            int num14 = num9 - (num11 * 8);
            int num15 = num14 / 2;
            int num16 = num13;
            int num17 = num14 - (num15 * 2);
            int num18 = this.columnWord32[num16 + (num17 * 8)];
            int num19 = ((((num2 + (num7 * 0x800)) + (num12 * 0x40)) + (num15 * 0x10)) + num18) * 4;
            this.gsmem[num19] = data[index];
            this.gsmem[num19 + 1] = data[index + 1];
            this.gsmem[num19 + 2] = data[index + 2];
            this.gsmem[num19 + 3] = data[index + 3];
            index += 4;
        }
    }
}

private void writeTexPSMCT16(int dbp, int dbw, int dsax, int dsay, int rrw, int rrh, byte[] data)
{
    int index = 0;
    int num2 = dbp * 0x40;
    for (int i = dsay; i < (dsay + rrh); i++)
    {
        for (int j = dsax; j < (dsax + rrw); j++)
        {
            int num5 = j / 0x40;
            int num6 = i / 0x40;
            int num7 = num5 + (num6 * dbw);
            int num8 = j - (num5 * 0x40);
            int num9 = i - (num6 * 0x40);
            int num10 = num8 / 0x10;
            int num11 = num9 / 8;
            int num12 = this.block16[num10 + (num11 * 4)];
            int num13 = num8 - (num10 * 0x10);
            int num14 = num9 - (num11 * 8);
            int num15 = num14 / 2;
            int num16 = num13;
            int num17 = num14 - (num15 * 2);
            int num18 = this.columnWord16[num16 + (num17 * 0x10)];
            int num19 = this.columnHalf16[num16 + (num17 * 0x10)];
            int num20 = ((((num2 + (num7 * 0x800)) + (num12 * 0x40)) + (num15 * 0x10)) + num18) * 4;
            this.gsmem[num20 + num19] = data[index];
            this.gsmem[(num20 + num19) + 1] = data[index + 1];
            index += 2;
        }
    }
}

public byte[] Unswizzle(byte[] data, int width, int height)
{
    byte[] buffer = new byte[data.Length];
    this.gsmem = new byte[0x400000];
    if (this.textureInfo.BitsPerPixel == 8)
    {
        int rrw = width / 2;
        int rrh = height / 2;
        this.writeTexPSMCT32(0, rrw / 0x40, 0, 0, rrw, rrh, data);
        this.readTexPSMT8(0, width / 0x40, 0, 0, width, height, ref buffer);
    }
    else if (this.textureInfo.BitsPerPixel == 4)
    {
        int num3 = width / 2;
        int num4 = height / 2;
        this.writeTexPSMCT16(0, num3 / 0x40, 0, 0, num3, num4, data);
        this.readTexPSMT4(0, width / 0x40, 0, 0, width, height, ref buffer);
        byte[] buffer2 = new byte[data.Length];
        int[] numArray = new int[] { 5, 4, 7, 6, 1, 0, 3, 2 };
        int[] numArray2 = new int[] { 2, 3, 0, 1 };
        for (int i = 0; i < height; i++)
        {
            for (int j = 0; j < width; j++)
            {
                int index = j - (8 * (j / 8));
                int num8 = i - (4 * (i / 4));
                byte num9 = buffer[(i * (width / 2)) + (j / 2)];
                if ((j & 1) == 0)
                {
                    num9 = (byte) (num9 & 240);
                    num9 = (byte) (num9 >> 4);
                }
                else
                {
                    num9 = (byte) (num9 & 15);
                }
                int num10 = numArray[index];
                int num11 = numArray2[num8];
                int num12 = num10 + (8 * (j / 8));
                int num13 = num11 + (4 * (i / 4));
                if ((num12 & 1) == 0)
                {
                    buffer2[(num13 * (width / 2)) + (num12 / 2)] = (byte) (buffer2[(num13 * (width / 2)) + (num12 / 2)] & 15);
                    num9 = (byte) (num9 << 4);
                    buffer2[(num13 * (width / 2)) + (num12 / 2)] = (byte) (buffer2[(num13 * (width / 2)) + (num12 / 2)] | num9);
                }
                else
                {
                    buffer2[(num13 * (width / 2)) + (num12 / 2)] = (byte) (buffer2[(num13 * (width / 2)) + (num12 / 2)] & 240);
                    buffer2[(num13 * (width / 2)) + (num12 / 2)] = (byte) (buffer2[(num13 * (width / 2)) + (num12 / 2)] | num9);
                }
            }
        }
        buffer = buffer2;
    }
    this.gsmem = null;
    GC.Collect();
    return buffer;
}