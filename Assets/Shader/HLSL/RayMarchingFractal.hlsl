// 位置を受け取り、物体までの距離を計算する関数
float Dist(float3 p)
{
    // 反復関数系で適当なフラクタルを描画してみる
    float scale = 1.0;

    // 適当な回数繰り返して空間を折りたたむ
    for (int i = 0; i < 12; ++i)
    {
        // 左右上下前後をそれぞれ対称化する
        p = abs(p);

        // 45度の平面で区切って対称化する
        if (p.x > p.y)
            p.xy = p.yx;
        if (p.x > p.z)
            p.xz = p.zx;
        if (p.z > p.y)
            p.zy = p.yz;

        // 時間を使って適当に位置をズラす
        p -= float3(0.1, 0.2, 0.15) + sin(float3(0, 1, 2) + _Time.y * float3(4, 3, 2.5) + i) * 0.05;

        // 空間を縮小して次のステップに進む
        scale *= 2.0;
        p *= 2.0;
    }

    // 折りたたまれた空間の中で、球を描画する
    return (length(p) - 0.3) / scale;
}

//法線を計算する
float3 CalcNormal(float3 p)
{
    //距離関数の勾配を取って正規化すると法線が計算できる
    float2 ep = float2(0, 0.001);
    return normalize(
        float3(
            Dist(p + ep.yxx) - Dist(p),
            Dist(p + ep.xyx) - Dist(p),
            Dist(p + ep.xxy) - Dist(p)
        )
    );
}

//マーチングループの本体
void RayMarchingFractal_float(
    float3 RayPosition,
    float3 RayDirection,
    out bool Hit,
    out float3 HitPosition,
    out float3 HitNormal
)
{
    float3 pos = RayPosition;

    //各ピクセルごとに64回のループをまわす
    for(int i = 0; i < 64; i ++)
    {
        //距離関数の分だけレイを進める
        float d = Dist(pos);
        pos += d * RayDirection;

        //距離関数がある程度小さければ衝突している見なす
        if(d < 0.001)
        {
            Hit = true;
            HitPosition = pos;
            HitNormal = CalcNormal(pos);
            return;
        }
    }
}