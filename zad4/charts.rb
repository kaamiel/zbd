require 'squid'

data1 = {
    '1-1-1' => {
        postgres: {
            min: 2.1294,
            avg: 8.7369,
            max: 14.954,
        },
        redis: {
            min: 0.548,
            avg: 2.9644,
            max: 15.7084,
        },
    },
    '2-2-2' => {
        postgres: {
            min: 1.3636,
            avg: 6.0588,
            max: 30.9652,
        },
        redis: {
            min: 0.4114,
            avg: 3.0234,
            max: 41.8796,
        },
    },
    '4-4-4' => {
        postgres: {
            min: 1.5714,
            avg: 9.5105,
            max: 35.2814,
        },
        redis: {
            min: 0.4718,
            avg: 2.8551,
            max: 38.7316,
        },
    },
    '1-2-2' => {
        postgres: {
            min: 1.7974,
            avg: 9.5001,
            max: 18.5238,
        },
        redis: {
            min: 0.478,
            avg: 3.1611,
            max: 28.3676,
        },
    },
}

data2 = {
    '1-1-1' => {
        postgres: {
            2 => 2,
            3 => 5,
            4 => 14,
            5 => 88,
            6 => 45,
            7 => 6,
            8 => 12,
            9 => 46,
            10 => 182,
            11 => 139,
            12 => 38,
            13 => 4,
        },
        redis: {
            0 => 1,
            1 => 28,
            2 => 201,
            3 => 145,
            4 => 152,
            5 => 57,
            6 => 3,
            7 => 5,
            8 => 4,
            9 => 2,
            10 => 1,
            11 => 1,
            13 => 1,
        },
    },
    '2-2-2' => {
        postgres: {
            1 => 44,
            2 => 145,
            3 => 61,
            4 => 209,
            5 => 213,
            6 => 145,
            7 => 119,
            8 => 76,
            9 => 21,
            10 => 12,
            11 => 11,
            12 => 7,
            13 => 6,
            14 => 6,
            15 => 11,
            16 => 6,
            17 => 11,
            18 => 12,
            19 => 11,
            20 => 7,
            21 => 11,
            22 => 7,
            23 => 5,
            24 => 5,
            25 => 2,
            29 => 1,
        },
        redis: {
            0 => 1,
            1 => 74,
            2 => 796,
            3 => 292,
            4 => 24,
            5 => 7,
            6 => 6,
            7 => 6,
            8 => 6,
            9 => 6,
            10 => 9,
            11 => 3,
            12 => 5,
            13 => 4,
            14 => 7,
            15 => 5,
            16 => 4,
            17 => 4,
            21 => 2,
            22 => 1,
            26 => 2,
            27 => 2,
            28 => 1,
            31 => 1,
            37 => 1,
        },
    },
    '4-4-4' => {
        postgres: {
            1 => 35,
            2 => 245,
            3 => 158,
            4 => 93,
            5 => 46,
            6 => 85,
            7 => 187,
            8 => 344,
            9 => 370,
            10 => 297,
            11 => 186,
            12 => 131,
            13 => 69,
            14 => 53,
            15 => 39,
            16 => 21,
            17 => 14,
            18 => 7,
            19 => 5,
            20 => 2,
            21 => 1,
            22 => 1,
            23 => 1,
            24 => 1,
            29 => 1,
        },
        redis: {
            0 => 2,
            1 => 558,
            2 => 992,
            3 => 490,
            4 => 147,
            5 => 32,
            6 => 11,
            7 => 9,
            8 => 6,
            9 => 9,
            10 => 7,
            11 => 5,
            12 => 4,
            13 => 5,
            14 => 12,
            15 => 4,
            16 => 7,
            17 => 5,
            18 => 7,
            19 => 7,
            20 => 8,
            21 => 9,
            22 => 2,
            23 => 3,
            24 => 4,
            25 => 1,
            26 => 3,
            27 => 2,
            28 => 2,
            29 => 1,
            30 => 2,
            32 => 2,
            36 => 2,
            37 => 1,
            39 => 1,
        },
    },
    '1-2-2' => {
        postgres: {
            2 => 11,
            3 => 12,
            4 => 21,
            5 => 86,
            6 => 48,
            7 => 22,
            8 => 15,
            9 => 9,
            10 => 23,
            11 => 82,
            12 => 99,
            13 => 92,
            14 => 46,
            15 => 11,
            16 => 1,
        },
        redis: {
            1 => 19,
            2 => 164,
            3 => 162,
            4 => 219,
            5 => 39,
            6 => 1,
            7 => 3,
            8 => 3,
            12 => 1,
            25 => 1,
            55 => 1,
        },
    },
}


data1.each do |k, v|
    Prawn::Document.generate("./charts/#{k}-min-avg-max.pdf", page_size: [600, 420], align: :center, margin: 0) do
        chart(v, type: :point, height: 420, formats: [:float, :float], labels: [true, true])
    end
end

data2.each do |k, v|
    zeros = v.values.map(&:keys).flatten.uniq.sort.map{ |k| [k, 0] }.to_h
    v_with_zeros = v.transform_values{ |h| zeros.merge(h) }
    Prawn::Document.generate("./charts/#{k}-grouped.pdf", page_size: [600, 420], align: :center, margin: 0) do
        chart(v_with_zeros, height: 420, labels: [true, true])
    end
end