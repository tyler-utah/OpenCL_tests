import copy
import random
import os
import shutil

# ins format: (type, location, strength)
# where type is L - load, S - store
# Location is x or y
# stregth is 0 - relaxed, 1 - release/acquire (depending on type), 2 - seq_cst

MP = {"ins": [("L", "x", 1), ("L", "y", 0), ("S", "y", 0), ("S", "x", 1)],
      }

SB = {"ins": [("S", "x", 2), ("L", "y", 2), ("S", "y", 2), ("L", "x", 2)],
      }

LB = {"ins": [("L", "x", 1), ("S", "y", 1), ("L", "y", 1), ("S", "x", 1)],
      }

TPTW = {"ins": [("S", "x", 2), ("S", "y", 2), ("S", "y", 2), ("S", "x", 2)],
      }

R = {"ins": [("S", "x", 2), ("S", "y", 2), ("S", "y", 2), ("L", "x", 2)],
      }


S = {"ins": [("S", "x", 0), ("S", "y", 1), ("L", "y", 1), ("S", "x", 0)],
      }


random.seed()
def four_random_ints(c_rank):
    while True:
        ret = []
        for i in range(4):
            ret.append(random.randint(0,2))
        for i in range(4):
            if ret[i] < c_rank[i]:
                return ret


def get_file_contents(fname):
    #print(fname)
    fhandle = open(fname, 'r')
    ret = fhandle.read()
    fhandle.close()
    return ret

def write_to_file(fname, s):
    fhandle = open(fname, 'w')
    fhandle.write(s)
    fhandle.close()
    

tests = {"MP": MP,
         "SB": SB,
         "LB": LB,
         "TPTW": TPTW, #2+2W
         "R":R,
         "S":S
}
#tests = {"MP" : MP}

num_variants = 6

variants = {}

def get_mo(test, mo, l):
    #print(mo)
    #print(l)
    #print(test["ins"][mo])
    if l[mo] == 0:
        return "memory_order_relaxed"
    elif l[mo] == 2:
        return "memory_order_seq_cst"
    assert (l[mo] == 1)
    if test["ins"][mo][0] == "S":
        return "memory_order_release"

#    if test["ins"][mo][0] != "L":
#        print(test)
    assert (test["ins"][mo][0] == "L")
    return "memory_order_acquire"



for t_name in tests:
    test = tests[t_name]
    print("removing previous tests:")
    cmd = "rm -rf ./interwg_base/test_set/" + t_name + "*"
    print(cmd)
    print()
    os.system(cmd)
    test_ranks = [test["ins"][i][2] for i in range(4)]
    #print(test_ranks)
    cmp_list = []
    for v in range(num_variants):
        loop = True
        while loop:
            loop = False
            t = four_random_ints(test_ranks)
            for i in range(len(cmp_list)):
                if cmp_list[i] == t:
                    loop = True
                    break

        cmp_list.append(t)
    variants[t_name] = cmp_list
    template = get_file_contents("test_set_templates/" + t_name + "/kernel.cl")
    for v in range(num_variants):
        os.mkdir("interwg_base/test_set/" + t_name + str(v))
        new_test = template
        for mo in range(4): #should parameterize this probably
            to_replace = get_mo(test, mo, cmp_list[v])
            r_string = "MEMORY_ORDER" + str(mo)
            new_test = new_test.replace(r_string, to_replace)
        write_to_file("interwg_base/test_set/" + t_name + str(v) + "/kernel.cl", new_test)
        shutil.copyfile("test_set_templates/" + t_name + "/config.txt", "interwg_base/test_set/" + t_name + str(v) + "/config.txt")
