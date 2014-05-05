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
    parser.add_argument('path_name',
                        help='path to the pipeline files')
    parser.add_argument('--mode',default=0, choices=[0,1],
                        help='aggregation mode')
    args = parser.parse_args()
    
    
    
    note_file = args.path_name + 'notes_file_' + args.path_name[:-1] + '.csv'
    stats_file = args.path_name + 'stats_file_' + args.path_name[:-1] + '.json'
    
    
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