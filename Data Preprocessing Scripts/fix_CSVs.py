# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

import numpy as np
import pandas as pd

# <codecell>

repos = pd.read_csv('repos_dump_in_csv.csv', dtype={'created_at': datetime})

# <codecell>

repos.head()

# <markdowncell>


# <codecell>

nans = repos['created_at'] == ""

# <codecell>

np.any(nans)

# <codecell>

temp = repos.head()
temp['year'] = pd.DatetimeIndex(pd.to_datetime(temp['created_at'])).year
pd.to_datetime(temp['created_at'])

# <codecell>

repos[repos['created_at'] == 'created_at']

# <codecell>

repos = repos.drop(repos.index[[2000000, 3000001, 4000002]])

# <codecell>

len(repos)

# <codecell>

stamp = pd.to_datetime(repos['created_at'])
repos['year'] = pd.DatetimeIndex(stamp).year

# <codecell>

repos.to_csv('final_repos.csv')

