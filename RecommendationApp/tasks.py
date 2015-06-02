#! /usr/bin/env python
# -*- coding: utf-8 -*-

from invoke import task, run

# print message
def acknowlege(msg = ''):
    print '\n=============================================================\n'
    print '    %s    '%(msg)
    print '\n=============================================================\n'

@task
def createdb():
    run('python db_create.py')
    acknowlege('Database created successfully named as app.db')

@task
def migratedb():
    run('python db_migrate.py')
    acknowlege('Database migrated successfully named as app.db')

@task
def upgradedb():
    run('python db_upgrade.py')
    acknowlege('Database upgraded successfully named as app.db')

@task
def downgradedb():
    run('python db_downgrade.py')
    acknowlege('Database downgraded successfully named as app.db')

@task
def deletedb():
    run('sudo rm app.db')
    acknowlege('Database deleted successfully named as app.db')

@task
def runapp():
    run('python run.py')

