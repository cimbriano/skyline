'''
Created on Apr 29, 2014

@author: maxp
'''


import argparse
import pandas as pd
import numpy as np
import json

def freneticity(col):
    return np.diff(col).mean()


def main():
    parser = argparse.ArgumentParser(prog='stats')
    parser.add_argument('note_file',
                        help='full path to the notes file')
    parser.add_argument('stats_file',
                        help='full path to the stats file')
    parser.add_argument('--mode',default=0, choices=[0,1],
                        help='aggregation mode')
    args = parser.parse_args()
   
   	note_file = args.note_file
   	stats_file = args.stats_file
    
    note_df = pd.read_csv(note_file)
    agg_df = note_df.groupby(['letter','octave'])
    cnt = agg_df.letter.count()
    avgLen = agg_df.duration.mean()
    avgVel = agg_df.velocity.mean()
    fren = agg_df.time_on.apply(freneticity)
    fren.fillna(0, inplace=True)

    
    cnt.name = 'count'
    avgLen.name = 'avgLen'
    avgVel.name = 'avgVelocity'
    fren.name = 'freneticity'
    
    ans  = pd.concat([cnt, avgVel, avgLen, fren], axis=1)
    for (letter,octave), v in ans.iterrows():
	    if not ansdict.has_key(letter): 
	        ansdict[letter] = {}
	    ansdict[letter][octave] = v.to_dict()
    
    with open(stats_file, 'w') as stats_json:
    	json.dump(ansdict, stats_json)


if __name__ == '__main__':
    main()