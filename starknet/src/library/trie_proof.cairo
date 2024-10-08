//! Library for Merkle Patricia Tree Utils

// *************************************************************************
//                                  IMPORTS
// *************************************************************************
use fossil::library::{
    words64_utils::{split_u256_to_u64_array, words64_to_nibbles},
    merkle_patricia_utils::{
        merkle_patricia_input_decode, get_next_hash, count_shared_prefix_len, extract_nibble
    },
    rlp_utils::{extract_data, to_rlp_array, is_rlp_item}, keccak_utils::keccak_words64
};
use fossil::types::Words64Sequence;

const EMPTY_TRIE_ROOT_HASH: u256 =
    0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421;

/// Verifies a Merkle Patricia Tree proof against a given path and root hash.
///
/// This function takes a `Words64Sequence` representing the path to be verified, a
/// `Words64Sequence`
/// representing the expected root hash, and a `Span<Words64Sequence>` containing the proof data. It
/// iterates through the proof data and verifies that the provided path matches the proof, and that
/// the root hash matches the calculated root hash based on the proof.
///
/// # Arguments
///
/// * `path` - A `Words64Sequence` representing the path to be verified.
/// * `root_hash` - A `Words64Sequence` representing the expected root hash.
/// * `proof` - A `Span<Words64Sequence>` containing the proof data.
///
/// # Returns
///
/// An ` Result<Option<Words64Sequence>>` containing the data associated with the verified path, or
/// `Result<felt252>` if the proof is invalid or the path does not exist in the Merkle Patricia
/// Tree.
///
/// # Error(Result<felt252>)
///
/// The function may returns Result<felt252> in the following cases:
/// - If the proof is empty and the provided `root_hash` is not the empty trie root hash.
/// - If a hash mismatch is encountered during the verification process.
/// - If an invalid node length is encountered during the verification process.
/// - If the path offset exceeds the length of the provided path.
pub fn verify_proof(
    path: Words64Sequence, root_hash: Words64Sequence, proof: Span<Words64Sequence>,
) -> Option<Words64Sequence> {
    let mut out = Words64Sequence { values: array![].span(), len_bytes: 0 };
    let proof_len = proof.len();

    if proof_len == 0 {
        if root_hash.values != split_u256_to_u64_array(EMPTY_TRIE_ROOT_HASH) {
            return Option::None;
        } else {
            return Option::Some(out);
        }
    }

    let mut next_hash = Words64Sequence { values: array![].span(), len_bytes: 0 };
    let mut path_offset = 0;
    let mut i = 0_u32;

    let output = loop {
        if i == proof_len {
            break Option::Some(out);
        }

        let element_rlp = *(proof.at(i));

        if i == 0 {
            if root_hash != keccak_words64(element_rlp) {
                panic!("Root hash mismatch");
            }
        } else {
            if next_hash != keccak_words64(element_rlp) {
                panic!("Hash mismatch");
            }
        }

        let node = to_rlp_array(element_rlp);
        let node_len = node.len();

        if node_len == 2 {
            let node_element = *node.at(0);
            let node_path = merkle_patricia_input_decode(
                extract_data(element_rlp, node_element.position, node_element.length)
            );
            path_offset +=
                count_shared_prefix_len(
                    path_offset, words64_to_nibbles(path, 0).span(), node_path.span(), 0
                );

            if i == proof_len - 1 {
                if path_offset != path.len_bytes * 2 {
                    panic!("Path offset mismatch");
                }
                let node_element_at_one = *node.at(1);

                break Option::Some(
                    extract_data(
                        element_rlp, node_element_at_one.position, node_element_at_one.length
                    )
                );
            } else {
                let children = *node.at(1);
                if !is_rlp_item(children) {
                    next_hash = get_next_hash(element_rlp, children);
                } else {
                    next_hash =
                        keccak_words64(
                            extract_data(element_rlp, children.position, children.length)
                        );
                }
            }
        } else {
            if node_len != 17 {
                panic!("Invalid node length");
            }

            if i == proof_len - 1 {
                if path_offset + 1 == path.len_bytes * 2 {
                    break Option::Some(
                        extract_data(element_rlp, *node.at(16).position, *node.at(16).length)
                    );
                } else {
                    let node_children = extract_nibble(path, path_offset).try_into().unwrap();
                    let children = *node.at(node_children);
                    if children.length != 0 {
                        panic!("invalid children length");
                    }
                    break Option::None;
                }
            } else {
                if path_offset >= path.len_bytes * 2 {
                    panic!("Path offset mismatch");
                }
                let node_children = extract_nibble(path, path_offset).try_into().unwrap();
                let children = *node.at(node_children);

                path_offset += 1;

                if !is_rlp_item(children) {
                    next_hash = get_next_hash(element_rlp, children);
                } else {
                    next_hash =
                        keccak_words64(
                            extract_data(element_rlp, children.position, children.length)
                        );
                }
            }
        }
        i += 1;
    };
    output
}

#[cfg(test)]
mod tests {
    use super::Words64Sequence;

    #[test]
    fn test_verify_proof_anvil() {
        let out = super::verify_proof(proof_path_anvil(), state_root_anvil(), proof_anvil().span());
        match out {
            Option::Some(value) => { println!("value: {:?}", value); },
            Option::None => panic!("Error"),
        };
    }

    fn proof_path() -> Words64Sequence {
        Words64Sequence {
            values: array![
                16242634080300865914, 9377938528222421349, 9284578564931001247, 895019019097261264
            ]
                .span(),
            len_bytes: 32
        }
    }

    fn block_state_root() -> Words64Sequence {
        Words64Sequence {
            values: array![
                2325475127108968072, 11876231566175855444, 16474141678601410074, 6802953270526873938
            ]
                .span(),
            len_bytes: 32
        }
    }

    fn proof() -> Array<Words64Sequence> {
        let p0 = Words64Sequence {
            values: array![
                17942923246514633984,
                1217778639264257798,
                3243279504191013180,
                14723370821652241320,
                11876781802560999291,
                11645881558321686972,
                13871344797908757793,
                2362118107784989529,
                3729048587844204394,
                127498199932513093,
                12830234107242481793,
                17092578610358934796,
                6292994657085071411,
                2813153997891533456,
                15503051937804526418,
                14693378565221983783,
                17309229813288485536,
                10024440226435918317,
                17991830461303330473,
                4612901929982347652,
                6728153008232095548,
                11530644071876706148,
                5830808610847735054,
                16199323514295596694,
                17056905241327656581,
                3287855021194173693,
                10613910810295207997,
                5021072433707118047,
                3125461990629308481,
                2930894008894207662,
                7358759186577549186,
                4980921837089693493,
                8183590806986482414,
                11990748934712803801,
                10163789206891404797,
                8803125258096371931,
                449984146355388308,
                10753009927459337991,
                6606257214577321552,
                5987708696335975542,
                6731394593750136673,
                10833255907889029430,
                12697098198135606904,
                14357847415158140774,
                675693620912083882,
                4060171207335649390,
                10959951412951310105,
                1521995407996711912,
                16257486666495912220,
                10086620457743506848,
                16638145092707550595,
                17419406976225753539,
                10089725536367957483,
                9495911683512459393,
                11593171291811983960,
                11792517165791113656,
                4895961046210392611,
                1838108385884030291,
                1342183777993664401,
                1779608552166152062,
                14590500149490734592,
                7233715467461549812,
                1602895442170187786,
                15789562821152661057,
                12911895218267247544,
                5005802232216386625,
                1278861440
            ]
                .span(),
            len_bytes: 532
        };
        let p1 = Words64Sequence {
            values: array![
                17942923244738002036,
                14091505668525627713,
                127595607468770955,
                14464723023390202793,
                6980082003473802304,
                9601601048021730404,
                5529794693391152768,
                5889512417837633956,
                13278470775995668071,
                15488135662083124473,
                3002144276268718023,
                11903802511212740083,
                2434571989358125288,
                4738748543702438982,
                5501769167061539283,
                2185505204094206128,
                7129020752880980896,
                12485375477713357826,
                6661748961287167587,
                18191139256969723045,
                3610581871429128975,
                11582432844009657382,
                9645388845494142614,
                9754462832787937759,
                4709210518005686277,
                12150975347004084747,
                616688066739104737,
                5575281238288057808,
                7428123532826660262,
                17721559692315513831,
                5079594468525081105,
                18235043778610372534,
                11055917566303336166,
                6455147692256571539,
                5764962801693311431,
                10288808963385045839,
                7675896576345268961,
                9293562911957915235,
                8691527906856959629,
                1738444757386568888,
                9305652637269288906,
                51811200222139614,
                8888265280762330282,
                14524679145488596041,
                9819251861923219301,
                17403932533129781321,
                9373509069627139796,
                8071946781870098717,
                7189715427262121833,
                13254307551353470368,
                13929239358694638774,
                3323867728859288133,
                5639510516736375882,
                10675959169638595762,
                11586449579726895511,
                12695685349391250400,
                3892665808819217344,
                13099507433914104163,
                17555302808554381496,
                18290763522747304821,
                17510008276672498745,
                14617740804235196967,
                7234927413228841193,
                2320980344515819390,
                15293163543411524350,
                10443481308489299521,
                3625479296
            ]
                .span(),
            len_bytes: 532
        };
        let p2 = Words64Sequence {
            values: array![
                17942923246421251023,
                3640764499659914420,
                2791107143720951752,
                869960194458923989,
                8935750303210470827,
                13352226856629335718,
                12860175709241677169,
                14633126000066538558,
                17194959204819957066,
                5711877833352612650,
                14520099043161336025,
                9518677785407611042,
                11363321391149719650,
                8576279313470886518,
                15675455501418712831,
                16563505312137505719,
                10581790595937873824,
                12357581386672092770,
                8056909322651129103,
                9813957824189302960,
                3473288841179701237,
                11547197879578977649,
                10838227142599239594,
                14776803534903194076,
                8220683379979811082,
                11934721295773911193,
                4237943892407407332,
                1367617029543097553,
                14824670989617523888,
                12112326719658154350,
                1804963375099692098,
                2251517632522362282,
                8819134603906889924,
                10841519589895179805,
                7812220606182079886,
                477510230960296696,
                10263448853178728472,
                3603177440319404948,
                15040183370989621281,
                9910275579267507802,
                9854438029118333509,
                14403420933465337255,
                11205894973523416977,
                3028951006808812777,
                10067920134796614436,
                2833183322745577722,
                18060718925402459447,
                17880029830913734532,
                11661511280497484614,
                2485333035662381216,
                1811707466959021859,
                17609362752379940469,
                2000409049802699538,
                16397503150252632208,
                11585093557419807501,
                15597432321617457344,
                3232189959622022365,
                965708892475208695,
                1198188903097871967,
                1280836324366468493,
                2117000330819337971,
                911463284417408121,
                12202961262101421454,
                2470790674391149051,
                3454453542876115834,
                3118776730756999916,
                3311170176
            ]
                .span(),
            len_bytes: 532
        };
        let p3 = Words64Sequence {
            values: array![
                17942923248270049934,
                6231359831630494260,
                2152859957018227555,
                16647564877704871893,
                3843573533040019511,
                6515070224247622239,
                16260512682125278296,
                3354229107622833615,
                6501548066814856260,
                8455237917657784824,
                10192751762085883932,
                14075863860403471529,
                15508932927318630471,
                14110166540657419237,
                14663601038567050206,
                15584424800988123796,
                11721846551377976480,
                9353839973917990792,
                16583160182445044559,
                290248800132545689,
                1565451975707307673,
                11558334841915111084,
                4367533754328063530,
                9770938996501309662,
                13977085891967769346,
                6314286115846077413,
                17534193054686559138,
                4140807036867433039,
                2455700234506355399,
                5506390285271587412,
                8794672454068944651,
                12438273933501317909,
                3173142857132635277,
                14426011058195975170,
                584891102262606595,
                13183391593722001142,
                18271610957544195435,
                5899777014180039996,
                11608392664632673482,
                8025302138272109443,
                3842580134771478023,
                16129019386984979296,
                12660458630806664401,
                2463316166468437181,
                367239500696877786,
                4231172698996580549,
                164708788020207992,
                351320934440546431,
                9468638445133573973,
                12668793624010964384,
                3568277977457745297,
                10368149610397203264,
                10920768709302601242,
                3590211086060763251,
                11584819590100069214,
                1508818947400564324,
                17808368679926157666,
                15251633990746621508,
                15681673047941206966,
                13480056346520082068,
                16440275301439819408,
                17339729853759036145,
                4615803513748133879,
                12501182163578712326,
                17149252408863591718,
                8852572123960341184,
                1878120320
            ]
                .span(),
            len_bytes: 532
        };
        let p4 = Words64Sequence {
            values: array![
                17942923247845898940,
                17080131405297685566,
                1745119090733098488,
                4929267205406682916,
                15764556490605879191,
                12496085608630043588,
                11194716596372706301,
                18138467496623851038,
                534966900579370409,
                10622213317950969906,
                17710771635472669521,
                543700910774437184,
                4240397518953422949,
                4753266609006871546,
                15145633717412671784,
                4901891915972960219,
                968216691679276704,
                16557313672048347416,
                8910908626489041501,
                600823235988672424,
                14639505654724239108,
                11544282085871976398,
                9421142544580177389,
                10047081297064874007,
                12544328975774975501,
                6890714986575994956,
                7229834159261777692,
                9024721284803330640,
                2152070484972595592,
                10585043116145567531,
                13006690862205870427,
                4338025023724779059,
                11043573623684207455,
                1482070896895568434,
                9153954582054538162,
                10534950040069586309,
                6855511571912197620,
                10303251315978222927,
                9374812303298324282,
                16946157034005017333,
                6263172824684333296,
                13734982067079396923,
                16062449432662721129,
                15373701372019868808,
                6797547176399138216,
                4426415221700468924,
                15598600004310450561,
                8693359672589869283,
                8848857109694095119,
                10213214085820023712,
                15680463326032649198,
                2392030192258741477,
                14294050406566111000,
                16805895515326832808,
                11532776538443720104,
                17291317116015102559,
                1528246407445028490,
                18072977494459706505,
                1125996954895052375,
                1176194578127055018,
                15508676412740848415,
                17058273869175247822,
                18041596768589184739,
                11911655382272239269,
                10729053351006094826,
                8803599308258293840,
                916063872
            ]
                .span(),
            len_bytes: 532
        };
        let p5 = Words64Sequence {
            values: array![
                17942923244298164187,
                15580113649541455684,
                11128905629361034390,
                13127800849608250231,
                13233067642107030128,
                2162497567404943209,
                2217497151644374019,
                5542964175644415066,
                3569742945057787610,
                2832848232140047026,
                8067910432031496664,
                6693835298140305571,
                8697515277755916347,
                13174723512498501381,
                3202791948422776491,
                13334506031149789011,
                14601130401690410144,
                3032037130427943273,
                2475184367479809544,
                8836000723227759332,
                3451002586086516639,
                11582467823058586978,
                14676641259618913181,
                7668056209801305500,
                9279711075875657939,
                14168590983986837356,
                6461462715282493119,
                16016242049602993364,
                18365306914476444593,
                18155594291477320630,
                12795527533009582709,
                10277456910075949674,
                16928754362431109765,
                13735803631893611721,
                11815541302123432663,
                14923677620943823530,
                5934150705900276535,
                15581463271735641158,
                17861139538983600196,
                5560846098730110403,
                7911867922831685931,
                16674032567206317155,
                10488339296714835213,
                17678025135215348216,
                15652583305368642596,
                13558798411845902405,
                12183411214280295599,
                1476813283571967337,
                14000608578400299205,
                2440785678380577696,
                14301278579246027862,
                4914707122588786598,
                15287986751765070739,
                16785911430550790999,
                11568996648387775148,
                2366336585288678633,
                12738291994325407954,
                5864790124384873375,
                8259640472185299702,
                7978926522296656802,
                9577398997427925372,
                15351800835532985050,
                18082410043183526480,
                17913530104930448468,
                9815215295751171592,
                4422070198154032435,
                3467270784
            ]
                .span(),
            len_bytes: 532
        };
        let p6 = Words64Sequence {
            values: array![
                17938260219097658277,
                9891822393463273788,
                2064392313220002794,
                16817409363590656418,
                10411754404756590744,
                430061643288343337,
                11827858672210837187,
                14759803722731802844,
                14588504159452962996,
                913073521303412802,
                10262240441277529814,
                4819777282693981600,
                13859091391672635296,
                10279920435517338716,
                16336556309965129660,
                16625152555247832712,
                11418901583884216277,
                9259577226681533591,
                11754791452698186234,
                15881757352925409999,
                17740076359491564862,
                12491118948026238385,
                6465619030987418565,
                6100852895395029578,
                1952785186013819957,
                16966614117563531424,
                12285002318614532553,
                15519503600348423987,
                17340685416662805324,
                726264576592390908,
                8421504
            ]
                .span(),
            len_bytes: 243
        };
        let p7 = Words64Sequence {
            values: array![
                17899166613764872570,
                9377938528222421349,
                9284578564931001247,
                895019019097261264,
                13278573522315157529,
                11254050738018229226,
                16872101704597074970,
                8839885802225769251,
                17633069546125622176,
                5635966238324062822,
                4466071473455465888,
                16386808635744847773,
                5287805632665950919
            ]
                .span(),
            len_bytes: 104
        };
        array![p0, p1, p2, p3, p4, p5, p6, p7]
    }

    fn proof_anvil() -> Array<Words64Sequence> {
        let p0 = Words64Sequence {
            values: array![
                17942712139336575714,
                7322395115247864981,
                9696471292711729221,
                903568900370751984,
                303466977183566258,
                11898575076475314378,
                3991848043007121262,
                6046858721407677519,
                18175509357028999328,
                15112132244661889056,
                9908271223616860312,
                15984310952959735594,
                15645765083108267529,
                11550636105473166511,
                13853435974836576514,
                4917632100704164602,
                12545657914460188587,
                3278796710592654079,
                15077259400518931795,
                11160137659121872107,
                15290704655941018102,
                17606666201497989028,
                5678846447600309516,
                17424691244819712972,
                9741603735323954820,
                4169780624201130431,
                16551956980600305999,
                100293760416089331,
                13085746178344811688,
                13209782696894570687,
                11171711326550783883,
                3840087987042649245,
                9177926302248298196,
                8558242035327423104,
                9268512851893846598,
                7566972708875085535,
                5382790851443268599,
                9207975057986363288,
                1879022028165325061,
                9748942525133075881,
                4640373473810958964,
                12819256305757250093,
                757307776
            ]
                .span(),
            len_bytes: 340
        };
        let p1 = Words64Sequence {
            values: array![
                17893224083919773945,
                13135060841128972854,
                7916313373805331188,
                7448579461331849594,
                16081673001799608960,
                9259542123273814144,
                11556784118908757093,
                2485209825384507840,
                8852124926135473986,
                14848727627625325413,
                4292736
            ]
                .span(),
            len_bytes: 83
        };
        let p2 = Words64Sequence {
            values: array![
                17900014253268261798,
                10085541635936464740,
                16284463465276870940,
                10366490994992567568,
                6153155932545631233,
                9268569323206369822,
                11769840144037554458,
                6465292778623532740,
                6868390785500968809,
                1665945311227487514,
                1288531408124322443,
                17170933329769257990,
                11062663716857276275,
                742574
            ]
                .span(),
            len_bytes: 107
        };
        array![p0, p1, p2]
    }

    fn proof_path_anvil() -> Words64Sequence {
        Words64Sequence {
            values: array![
                18302765068955940618,
                12587956436486716937,
                4480421445994798380,
                11730699817693045862
            ]
                .span(),
            len_bytes: 32
        }
    }

    fn state_root_anvil() -> Words64Sequence {
        Words64Sequence {
            values: array![
                15235604485124334757,
                6947789618411539857,
                14068058166389502555,
                10254785038972823550
            ]
                .span(),
            len_bytes: 32
        }
    }
}
