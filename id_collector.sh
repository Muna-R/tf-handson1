#!/bin/bash

echo "VPC ID: $(terraform output vpc_id)" > infra.txt
echo "publicSubnet-1a ID: $(terraform output publicSubnet-1a_id)" >> infra.txt
echo "publicSubnet-1b ID: $(terraform output publicSubnet-1b_id)" >> infra.txt
echo "privateSubnet-1a ID: $(terraform output privateSubnet-1a_id)" >> infra.txt
echo "privateSubnet-1b ID: $(terraform output privateSubnet-1b_id)" >> infra.txt
echo "Internet gateway ID: $(terraform output igw_id)" >> infra.txt
echo "EIP ID: $(terraform output eip)" >> infra.txt
echo "NatGAteway ID: $(terraform output nat_gateway)" >> infra.txt
echo "PUBLIC rout table ID: $(terraform output public_rt_table)" >> infra.txt
echo "PRIvate rt table ID: $(terraform output private_rt_table)" >> infra.txt
echo "SECUrity group ID: $(terraform output public_sgrp)" >> infra.txt
echo "EC2-1a ID: $(terraform output public_1a_ec2)" >> infra.txt
echo "EC2-1b ID: $(terraform output public_1b_ec2)" >> infra.txt





