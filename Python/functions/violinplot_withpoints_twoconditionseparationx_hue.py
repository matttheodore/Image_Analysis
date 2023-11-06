# Violin Plot, strplot function

import matplotlib.pyplot as plt
import seaborn as sns


def violin_strplot_twoconditionx_hue(df, metric, xcondition1, xcondition2, huecondition): #new_df_name='new_df'
    # Create a deep copy of the DataFrame
    df_copy = df.copy()
    
    # Create a new column combining 'xcondition1' and 'xcondition2'
    df_copy['xcondition1_xcondition2'] = df_copy[xcondition1].astype(str) + "_" + df_copy[xcondition2].astype(str)
    
    plt.figure(figsize=(15, 6))
    
    # Create the violin plot
    sns.violinplot(x='xcondition1_xcondition2', y=metric, data=df_copy, inner=None, dodge=True, color='gray', alpha=0.5)
    
    # Create the strip plot
    sns.stripplot(x='xcondition1_xcondition2', y=metric, data=df_copy, hue=huecondition, dodge=True, jitter=True, marker='o', alpha=0.5)
    
    plt.title(f'{metric.capitalize()} Intensity Across {xcondition1} and {xcondition2}, Colored by {huecondition}')
    plt.legend(title=huecondition, bbox_to_anchor=(1, 1), loc=2)
    plt.tight_layout()
    plt.show()
    
    # Save the new DataFrame to the global environment
    #globals()[new_df_name] = df_copy

