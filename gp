import tushare as ts
import xlrd as xd
import datetime
import time
import random
import pandas as pd
import os
import re
from datetime import datetime, date, timedelta
#获取日期
times = time.time()
local_time = time.localtime(times)
today1=time.strftime("%Y%m%d",local_time)

yesterday = (date.today() + timedelta(days = -1)).strftime("%Y%m%d")
print(yesterday)
ts.set_token('dfa6cf19bbe2abc1a3e8cf29a23f1a64ef4525aa1def495d4cf15bf7')

pro = ts.pro_api()
#打开所有数据列表，并且转化成List

#主 ST 科 创 京
class gp(object):
    def __init__(self,bankuai,Date,num):
        self.bankuai = bankuai
        self.Date = Date
        self.num = num
    def main(self):
        data = xd.open_workbook('/home/yangguang/桌面/all.xlsx')  # 打开excel表所在路径
        sheet = data.sheet_by_name(self.bankuai)  # 读取数据，以excel表名来打开
        d = []
        for r in range(sheet.nrows):  # 将表中数据按行逐步添加到列表中，最后转换为list结构
            data1 = []
            for c in range(sheet.ncols):
                data1.append(sheet.cell_value(r, c))
            d.append(list(data1))
        print(d)
        list1 = []
        for i in d:
            list1.append(i[0])
        # 随机取出来1000条代码
        code1 = random.sample(list1, int(self.anum))
        code = ",".join(code1)
        print(code)

        df = pro.daily(ts_code=code, start_date=self.Date, end_date=self.Date)
        df1 = pro.daily(ts_code=code, start_date=yesterday, end_date=yesterday)
        print(df)

        # 选择所有行并挑选出来想要的字段
        df = (df.loc[0:, ['ts_code', 'open', 'close']])
        df1 = (df1.loc[0:, ['ts_code', 'close']])
        # 把数据写入到表格当中
        df.to_excel('/home/yangguang/桌面/1.xlsx', index=False)
        df1.to_excel('/home/yangguang/桌面/2.xlsx', index=False)
        #
        temp1 = pd.read_excel('/home/yangguang/桌面/1.xlsx', sheet_name='Sheet1')
        temp2 = pd.read_excel('/home/yangguang/桌面/2.xlsx', sheet_name='Sheet1')
        temp3 = pro.stock_basic(**{
            "ts_code": "",
            "name": "",
            "exchange": "",
            "market": "",
            "is_hs": "",
            "list_status": "",
            "limit": "",
            "offset": ""
        }, fields=[
            "ts_code",
            "name",
            "industry",
        ])
        table = temp1.merge(temp2, on='ts_code')
        # 计算百分比
        a = (table.close_x - table.close_y) / table.close_x
        table['差值'] = a
        table2 = table.merge(temp3, on='ts_code')
        table2 = table2[table2['差值'] > 0.16]
        table2.to_excel('/home/yangguang/桌面/{}.xlsx'.format(today1 + self.bankuai), index=False)
        os.remove('/home/yangguang/桌面/1.xlsx')
        os.remove('/home/yangguang/桌面/2.xlsx')
zhuba=gp('主','20220104','1000')
zhuba.main()
time.sleep(3)
chuangye=gp('创','20220104','900')
chuangye.main()
