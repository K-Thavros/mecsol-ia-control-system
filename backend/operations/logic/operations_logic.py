import random

def get_operations_status(db):
    """Calculates a summary of the current operational status."""
    personnel = db.get('personnel', [])
    equipment = db.get('equipment', [])
    projects = db.get('projects', [])

    assigned_personnel = sum(1 for p in personnel if p['status'] == 'assigned')
    total_personnel = len(personnel)
    personnel_utilization = (assigned_personnel / total_personnel * 100) if total_personnel > 0 else 0

    in_use_equipment = sum(1 for e in equipment if e['status'] == 'in_use')
    total_equipment = len(equipment)
    equipment_utilization = (in_use_equipment / total_equipment * 100) if total_equipment > 0 else 0
    
    active_projects_count = sum(1 for p in projects if p['status'] == 'active')
    pending_projects_count = sum(1 for p in projects if p['status'] == 'pending')

    return {
        "active_projects_count": active_projects_count,
        "pending_projects_count": pending_projects_count,
        "personnel_utilization": personnel_utilization,
        "equipment_utilization": equipment_utilization,
        "total_personnel": total_personnel,
        "total_equipment": total_equipment
    }

def schedule_projects(db, weights):
    """Calculates a priority score for pending projects and sorts them."""
    pending_projects = [p for p in db.get('projects', []) if p.get('status') == 'pending']
    personnel = db.get('personnel', [])
    
    available_personnel_skills = set()
    for person in personnel:
        if person['status'] == 'available':
            for skill in person.get('skills', []):
                available_personnel_skills.add(skill)

    scheduled_list = []
    for project in pending_projects:
        required_skills = project.get('required_skills', [])
        if not required_skills:
            resource_fit_score = 1.0
        else:
            fit_count = sum(1 for skill in required_skills if skill in available_personnel_skills)
            resource_fit_score = fit_count / len(required_skills)
        
        priority_score = (
            weights['w_m'] * project.get('project_margin', 0) +
            weights['w_u'] * project.get('urgency_score', 0) +
            weights['w_r'] * resource_fit_score
        )
        
        project_copy = project.copy()
        project_copy['resource_fit_score'] = resource_fit_score
        project_copy['priority_score'] = priority_score
        scheduled_list.append(project_copy)

    scheduled_list.sort(key=lambda x: x['priority_score'], reverse=True)
    return scheduled_list


def allocate_resources(db):
    """Simulates a proactive resource allocation for active projects."""
    active_projects = [p for p in db.get('projects', []) if p.get('status') == 'active']
    
    available_personnel = [p for p in db.get('personnel', []) if p.get('status') == 'available']
    available_equipment = [e for e in db.get('equipment', []) if e.get('status') == 'available']
    
    allocation_plan = []

    for project in active_projects:
        project_allocation = {
            "project_id": project.get('project_id'),
            "assigned_personnel": [],
            "assigned_equipment": []
        }
        
        required_skills = project.get('required_skills', [])
        for skill in required_skills:
            person_to_assign = None
            for i, person in enumerate(available_personnel):
                if skill in person.get('skills', []):
                    person_to_assign = available_personnel.pop(i)
                    project_allocation["assigned_personnel"].append(person_to_assign)
                    break
        
        if project.get('requires_equipment'):
            if available_equipment:
                equipment_to_assign = available_equipment.pop(0)
                project_allocation["assigned_equipment"].append(equipment_to_assign)

        allocation_plan.append(project_allocation)
        
    return allocation_plan
